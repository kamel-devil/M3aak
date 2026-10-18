import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/compare/controllers/compare_controller.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/search_product/domain/models/author_model.dart';
import 'package:kk_thotix_m3aak/features/search_product/domain/models/suggestion_product_model.dart';
import 'package:kk_thotix_m3aak/features/search_product/domain/services/search_product_service_interface.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:provider/provider.dart';

class SearchProductController with ChangeNotifier {
  final SearchProductServiceInterface? searchProductServiceInterface;
  SearchProductController({required this.searchProductServiceInterface});

  int _filterIndex = 0;
  List<String> _historyList = [];
  List<AuthorModel>? _authorsList;
  List<AuthorModel>? _publishingHouseList;
  List<AuthorModel>? _sellerAuthorsList;
  List<AuthorModel>? _sellerPublishingHouseList;

  int get filterIndex => _filterIndex;
  List<String> get historyList => _historyList;
  List<AuthorModel>? get authorsList => _authorsList;
  List<AuthorModel>? get publishingHouseList => _publishingHouseList;
  List<AuthorModel>? get sellerAuthorsList => _sellerAuthorsList;
  List<AuthorModel>? get sellerPublishingHouseList =>
      _sellerPublishingHouseList;

  final List<int> _selectedAuthorIds = [];
  List<int> get selectedAuthorIds => _selectedAuthorIds;

  final List<int> _publishingHouseIds = [];
  List<int> get publishingHouseIds => _publishingHouseIds;

  List<int> _selectedSellerAuthorIds = [];
  List<int> get selectedSellerAuthorIds => _selectedSellerAuthorIds;

  List<int> _sellerPublishingHouseIds = [];
  List<int> get sellerPublishingHouseIds => _sellerPublishingHouseIds;

  double minPriceForFilter = AppConstants.minFilter;
  double maxPriceForFilter = AppConstants.maxFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _productTypeIndex = 0;
  int get productTypeIndex => _productTypeIndex;

  String? _minPrice;
  String? get minPrice => _minPrice;

  String? _maxPrice;
  String? get maxPrice => _maxPrice;

  void setMinMaxPriceForFilter(RangeValues currentRangeValues) {
    minPriceForFilter = currentRangeValues.start;
    maxPriceForFilter = currentRangeValues.end;
    notifyListeners();
  }

  bool _isFilterApplied = false;
  bool _isSortingApplied = false;

  bool get isFilterApplied => _isFilterApplied;
  bool get isSortingApplied => _isSortingApplied;

  void setFilterApply(
      {bool? isFiltered, bool? isSorted, bool isUpdate = true}) {
    if (isFiltered != null) {
      _isFilterApplied = isFiltered;
    }

    if (isSorted != null) {
      _isSortingApplied = isSorted;
    }

    if (isFiltered != null && isSorted != null && isFiltered && isSorted) {
      _minPrice = null;
      _maxPrice = null;
    }

    if (isUpdate) {
      notifyListeners();
    }
  }

  String sortText = 'low-high';
  void setFilterIndex(int index) {
    _filterIndex = index;
    if (index == 0) {
      sortText = 'default';
    } else if (index == 1) {
      sortText = 'latest';
    } else if (index == 2) {
      sortText = 'a-z';
    } else if (index == 3) {
      sortText = 'z-a';
    } else if (index == 4) {
      sortText = 'low-high';
    } else if (index == 5) {
      sortText = 'high-low';
    }
    notifyListeners();
  }

  double minFilterValue = 0;
  double maxFilterValue = 0;
  void setFilterValue(double min, double max) {
    minFilterValue = min;
    maxFilterValue = max;
  }

  bool _isClear = true;
  bool get isClear => _isClear;

  Timer? _suggestionDebounce;
  int _latestSuggestionRequestId = 0;
  String _lastRequestedSuggestion = '';
  CancelToken? _suggestionCancelToken;
  final Map<String, List<SuggestionOptionData>> _suggestionCache = {};
  static const int _maxSuggestionCacheEntries = 30;

  void cleanSearchProduct({bool notify = false}) {
    // searchedProduct = ProductModel(products: []);
    searchedProduct = null;
    minFilterValue = 0;
    maxFilterValue = 0;
    _isClear = true;
    nameList = [];
    idList = [];
    slugList = [];
    suggestionOptions = [];
    suggestionModel = null;
    _suggestionDebounce?.cancel();
    _suggestionCancelToken?.cancel();
    _lastRequestedSuggestion = '';
    _latestSuggestionRequestId = 0;
    _suggestionCache.clear();

    // Clear the search controller to reset UI
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    }

    if (notify) {
      notifyListeners();
    }
  }

  void onSuggestionQueryChanged(String rawValue) {
    final String query = rawValue.trim();
    final String normalizedQuery = query.toLowerCase();
    _suggestionDebounce?.cancel();

    // If empty or very short, clear suggestions completely
    if (query.isEmpty || query.length < 2) {
      _clearSuggestions();
      _lastRequestedSuggestion = '';
      _suggestionCancelToken?.cancel();
      _suggestionCancelToken = null;
      notifyListeners();
      return;
    }

    // Don't re-request same query
    if (normalizedQuery == _lastRequestedSuggestion) {
      return;
    }

    // Fast path: serve from memory cache for previously fetched query
    final List<SuggestionOptionData>? cachedOptions =
        _suggestionCache[normalizedQuery];
    if (cachedOptions != null) {
      _lastRequestedSuggestion = normalizedQuery;
      _setSuggestionOptions(cachedOptions);
      notifyListeners();
      return;
    }

    // Debounce with 250ms delay to keep typing responsive while limiting requests.
    _suggestionDebounce = Timer(const Duration(milliseconds: 250), () {
      getSuggestionProductName(query);
    });
  }

  Future<void> getSuggestionProductName(String name) async {
    final String query = name.trim();
    final String normalizedQuery = query.toLowerCase();

    // Guard: empty query
    if (query.isEmpty || query.length < 2) {
      _clearSuggestions();
      return;
    }

    _lastRequestedSuggestion = normalizedQuery;
    final int requestId = ++_latestSuggestionRequestId;

    // Cancel previous in-flight request before starting new one
    _suggestionCancelToken?.cancel();
    _suggestionCancelToken = CancelToken();

    try {
      ApiResponseModel apiResponse = await searchProductServiceInterface!
          .getSearchProductName(query, cancelToken: _suggestionCancelToken);

      // Ignore stale responses if a newer query was requested
      if (requestId != _latestSuggestionRequestId) {
        return;
      }

      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _clearSuggestions();

        final data = apiResponse.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          suggestionModel = SuggestionModel.fromJson(data);

          if (suggestionModel?.products != null) {
            final Set<int> seenProductIds = <int>{};
            final List<SuggestionOptionData> options = <SuggestionOptionData>[];

            for (int i = 0; i < suggestionModel!.products!.length; i++) {
              final product = suggestionModel!.products![i];
              if (product.name != null &&
                  product.id != null &&
                  seenProductIds.add(product.id!)) {
                options.add(SuggestionOptionData(
                  name: product.name!,
                  id: product.id!,
                  slug: product.slug ?? '',
                ));
              }
            }

            _setSuggestionOptions(options);
            _setSuggestionCache(normalizedQuery, options);
          }
        }
      } else {
        _clearSuggestions();
        suggestionModel = null;
      }
    } on DioException catch (e) {
      // Handle cancellation silently
      if (e.type == DioExceptionType.cancel) {
        if (kDebugMode) {
          print('Suggestion request cancelled for query: $query');
        }
        return;
      }
      // Log other errors for debugging
      if (kDebugMode) {
        print('Error fetching suggestions: ${e.message}');
      }
      _clearSuggestions();
      suggestionModel = null;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in suggestions: $e');
      }
      _clearSuggestions();
      suggestionModel = null;
    }

    notifyListeners();
  }

  ProductModel? searchedProduct;
  bool _isPaginationLoading = false;
  bool get isPaginationLoading => _isPaginationLoading;

  Future searchProduct(
      {required String query,
      String? categoryIds,
      String? brandIds,
      String? authorIds,
      String? publishingIds,
      String? sort,
      String? priceMin,
      String? priceMax,
      required int offset,
      String? code}) async {
    if (query.isNotEmpty) {
      searchController.text = query;
    }

    if (offset == 1) {
      _isLoading = true;
    } else {
      _isPaginationLoading = true;
    }
    notifyListeners();

    ApiResponseModel apiResponse =
        await searchProductServiceInterface!.getSearchProductList(
            query,
            categoryIds,
            brandIds,
            authorIds,
            publishingIds,
            sort,
            priceMin,
            priceMax,
            offset,
            _productTypeIndex == 0
                ? 'all'
                : _productTypeIndex == 1
                    ? 'physical'
                    : 'digital',
            code: code);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        final ProductModel parsedProductModelResponse = ProductModel.fromJson(apiResponse.response!.data);
        searchedProduct = null;
        if (parsedProductModelResponse.products !=
            null) {
          searchedProduct = parsedProductModelResponse;

          if (searchedProduct?.minPrice != null) {
            minFilterValue = searchedProduct!.minPrice!;
            _minPrice = searchedProduct!.minPrice!.toString();
          }
          if (searchedProduct?.maxPrice != null) {
            maxFilterValue = searchedProduct!.maxPrice!;
            _maxPrice = searchedProduct!.maxPrice!.toString();
          }

          if (priceMax != null && priceMax.isNotEmpty) {
            _maxPrice = priceMax;
            maxFilterValue = double.tryParse(priceMax) ?? 0;
          }

          if (priceMin != null && priceMin.isNotEmpty) {
            _minPrice = priceMin;
            minFilterValue = double.tryParse(priceMin) ?? 0;
          }
        }
      } else {
        final ProductModel parsedProductModelResponse = ProductModel.fromJson(apiResponse.response!.data);
        if (parsedProductModelResponse.products !=
            null) {
          searchedProduct?.products?.addAll(
              parsedProductModelResponse.products!);
          searchedProduct?.offset =
              (parsedProductModelResponse.offset);
          searchedProduct?.totalSize =
              (parsedProductModelResponse.totalSize);
        }
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    _isPaginationLoading = false;
    notifyListeners();
  }

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  SuggestionModel? suggestionModel;
  List<String> nameList = [];
  List<int> idList = [];
  List<String> slugList = [];
  List<SuggestionOptionData> suggestionOptions = [];

  void _clearSuggestions() {
    nameList = [];
    idList = [];
    slugList = [];
    suggestionOptions = [];
  }

  void _setSuggestionOptions(List<SuggestionOptionData> options) {
    suggestionOptions = List<SuggestionOptionData>.from(options);
    nameList = options.map((option) => option.name).toList();
    idList = options.map((option) => option.id).toList();
    slugList = options.map((option) => option.slug).toList();
  }

  void _setSuggestionCache(String query, List<SuggestionOptionData> options) {
    if (_suggestionCache.length >= _maxSuggestionCacheEntries &&
        !_suggestionCache.containsKey(query)) {
      _suggestionCache.remove(_suggestionCache.keys.first);
    }
    _suggestionCache[query] = List<SuggestionOptionData>.from(options);
  }

  void initHistoryList() {
    _historyList = [];
    _historyList
        .addAll(searchProductServiceInterface!.getSavedSearchProductName());
  }

  int selectedSearchedProductId = 0;
  void setSelectedProductId(int index, int? compareId) {
    if (suggestionModel!.products!.isNotEmpty) {
      selectedSearchedProductId = suggestionModel!.products![index].id!;
    }
    if (compareId != null) {
      Provider.of<CompareController>(Get.context!, listen: false)
          .replaceCompareList(compareId, selectedSearchedProductId);
    } else {
      Provider.of<CompareController>(Get.context!, listen: false)
          .addCompareList(selectedSearchedProductId);
    }
    notifyListeners();
  }

  void saveSearchAddress(String searchAddress) async {
    searchProductServiceInterface!.saveSearchProductName(searchAddress);
    if (!_historyList.contains(searchAddress)) {
      _historyList.add(searchAddress);
    }
    notifyListeners();
  }

  void removeSearchAddress(int? index) async {
    _historyList.removeAt(index!);
    searchProductServiceInterface!.clearSavedSearchProductName();
    for (int i = 0; i < _historyList.length; i++) {
      searchProductServiceInterface!.saveSearchProductName(_historyList[i]);
    }
    notifyListeners();
  }

  void clearSearchAddress() async {
    searchProductServiceInterface!.clearSavedSearchProductName();
    _historyList = [];
    notifyListeners();
  }

  void setInitialFilerData() {
    _filterIndex = 0;
  }

  Future<void> getAuthorList(int? sellerId) async {
    ApiResponseModel apiResponse =
        await searchProductServiceInterface!.getAuthorList(sellerId);

    if (sellerId != null &&
        apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _sellerAuthorsList = [];

      apiResponse.response!.data.forEach((author) {
        _sellerAuthorsList!.add(AuthorModel.fromJson(author));
      });
    } else if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _authorsList = [];

      apiResponse.response!.data.forEach((author) {
        _authorsList!.add(AuthorModel.fromJson(author));
      });
    }
    notifyListeners();
  }

  Future<void> getPublishingHouseList(int? sellerId) async {
    ApiResponseModel apiResponse =
        await searchProductServiceInterface!.getPublishingHouse(sellerId);
    if (sellerId != null &&
        apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _sellerPublishingHouseList = [];
      apiResponse.response!.data.forEach((house) {
        _sellerPublishingHouseList!.add(AuthorModel.fromJson(house));
      });
    } else if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _publishingHouseList = [];
      apiResponse.response?.data.forEach((house) {
        _publishingHouseList?.add(AuthorModel.fromJson(house));
      });
    }
    notifyListeners();
  }

  void checkedToggleAuthors(int index, bool formShop) {
    if (formShop) {
      _sellerAuthorsList![index].isChecked =
          !_sellerAuthorsList![index].isChecked!;

      if (_sellerAuthorsList![index].isChecked ?? false) {
        if (!_selectedSellerAuthorIds.contains(_sellerAuthorsList![index].id)) {
          _selectedSellerAuthorIds.add(_sellerAuthorsList![index].id!);
        }
      } else {
        _selectedSellerAuthorIds.remove(_sellerAuthorsList![index].id!);
      }
    } else {
      _authorsList![index].isChecked = !_authorsList![index].isChecked!;

      if (_authorsList![index].isChecked ?? false) {
        if (!_selectedAuthorIds.contains(_authorsList![index].id)) {
          _selectedAuthorIds.add(_authorsList![index].id!);
        }
      } else {
        _selectedAuthorIds.remove(_authorsList![index].id!);
      }
    }
    notifyListeners();
  }

  void checkedTogglePublishingHouse(int index, bool fromShop,
      {bool fromHomePage = false}) {
    if (fromHomePage) {
      _sellerPublishingHouseIds = [];
      _publishingHouseList?.map((house) {
        house.isChecked = false;
      }).toList();
    }

    if (fromShop) {
      _sellerPublishingHouseList![index].isChecked =
          !_sellerPublishingHouseList![index].isChecked!;

      if (_sellerPublishingHouseList![index].isChecked ?? false) {
        if (!_sellerPublishingHouseIds
            .contains(_sellerPublishingHouseList![index].id!)) {
          _sellerPublishingHouseIds.add(_sellerPublishingHouseList![index].id!);
        }
      } else {
        _sellerPublishingHouseIds
            .remove(_sellerPublishingHouseList![index].id!);
      }
    } else {
      _publishingHouseList![index].isChecked =
          !_publishingHouseList![index].isChecked!;
      if (_publishingHouseList![index].isChecked ?? false) {
        if (!_publishingHouseIds.contains(_publishingHouseList![index].id)) {
          _publishingHouseIds.add(_publishingHouseList![index].id!);
        }
      } else {
        _publishingHouseIds.remove(_publishingHouseList![index].id!);
      }
    }
    notifyListeners();
  }

  void setProductTypeIndex(int index, bool notify) {
    _productTypeIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  void clearSellerAuthorHouse() {
    _selectedSellerAuthorIds = [];
    _sellerAuthorsList = [];
    _sellerPublishingHouseList = [];
    _sellerPublishingHouseIds = [];
  }

  Future<void> resetChecked(int? id, bool fromShop) async {
    if (fromShop) {
      getAuthorList(id);
      getPublishingHouseList(id);
    } else {
      getAuthorList(null);
      getPublishingHouseList(null);
    }
  }

  // Search product by barcode
  Future<void> searchProductByBarcode(String barcode) async {
    await searchProduct(query: '', offset: 1, code: barcode);
    saveSearchAddress(barcode);
  }

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    _suggestionCancelToken?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}

@immutable
class SuggestionOptionData {
  final String name;
  final int id;
  final String slug;

  const SuggestionOptionData({
    required this.name,
    required this.id,
    required this.slug,
  });
}
