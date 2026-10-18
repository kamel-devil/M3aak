import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/seller_product_controller.dart';
import 'package:kk_thotix_m3aak/features/search_product/controllers/search_product_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/domain/enums/vacation_duration_type.dart';
import 'package:kk_thotix_m3aak/helper/shop_helper.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/brand/controllers/brand_controller.dart';
import 'package:kk_thotix_m3aak/features/category/controllers/category_controller.dart';
import 'package:kk_thotix_m3aak/features/coupon/controllers/coupon_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/controllers/shop_controller.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/product_filter_dialog_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/search_widget.dart';
import 'package:kk_thotix_m3aak/features/home/screens/home_screens.dart';
import 'package:kk_thotix_m3aak/features/shop/screens/overview_screen.dart';
import 'package:kk_thotix_m3aak/features/shop/widgets/shop_info_widget.dart';
import 'package:kk_thotix_m3aak/features/shop/widgets/shop_product_view_list.dart';
import 'package:provider/provider.dart';

class TopSellerProductScreen extends StatefulWidget {
  final int? sellerId;
  final bool? temporaryClose;
  final bool? vacationStatus;
  final DateTime? vacationEndDate;
  final DateTime? vacationStartDate;
  final VacationDurationType? vacationDurationType;
  final String? name;
  final String? banner;
  final String? image;
  final bool fromMore;
  final int? totalReview;
  final int? totalProduct;
  final String? rating;
  const TopSellerProductScreen({
    super.key,
    this.sellerId,
    this.temporaryClose,
    this.vacationStatus,
    required this.vacationEndDate,
    required this.vacationStartDate,
    required this.vacationDurationType,
    this.name, this.banner,
    this.image,
    this.fromMore = false, this.totalReview, this.totalProduct, this.rating,
  });

  @override
  State<TopSellerProductScreen> createState() => _TopSellerProductScreenState();
}

class _TopSellerProductScreenState extends State<TopSellerProductScreen> with TickerProviderStateMixin{
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  bool vacationIsOn = false;
  TabController? _tabController;
  int selectedIndex = 0;

  void _load() async{
    await Provider.of<ShopController>(Get.context!, listen: false).getClearanceShopProductList('clearance_sale', '1', widget.sellerId.toString());
    await Provider.of<SellerProductController>(Get.context!, listen: false).getSellerProductList(widget.sellerId.toString(), 1, "");
    await Provider.of<ShopController>(Get.context!, listen: false).getSellerInfo(widget.sellerId.toString());
    await Provider.of<SellerProductController>(Get.context!, listen: false).getSellerWiseBestSellingProductList(widget.sellerId.toString(), 1);
    await Provider.of<SellerProductController>(Get.context!, listen: false).getSellerWiseFeaturedProductList(widget.sellerId.toString(), 1);
    await Provider.of<SellerProductController>(Get.context!, listen: false).getSellerWiseRecommendedProductList(widget.sellerId.toString(), 1);
    await Provider.of<CouponController>(Get.context!, listen: false).getSellerWiseCouponList(widget.sellerId!, 1);
    await Provider.of<CategoryController>(Get.context!, listen: false).getSellerWiseCategoryList(widget.sellerId!);
    await Provider.of<BrandController>(Get.context!, listen: false).getSellerWiseBrandList(widget.sellerId!);
  }

  @override
  void initState() {
    super.initState();
    vacationIsOn = ShopHelper.isVacationActive(
      context, startDate: widget.vacationStartDate,
      endDate: widget.vacationEndDate,
      vacationDurationType: widget.vacationDurationType,
      vacationStatus: widget.vacationStatus,
      isInHouseSeller: widget.sellerId == 0,
    );



    if(widget.fromMore){
      Provider.of<ShopController>(context, listen: false).setMenuItemIndex(1, notify: false);
    }else{
      Provider.of<ShopController>(context, listen: false).setMenuItemIndex(0, notify: false);
    }

    searchController.clear();
    _load();
    if(widget.fromMore){
      _tabController = TabController(length: 2, initialIndex: 1, vsync: this);
    }else{
      _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    }

    Provider.of<SearchProductController>(context, listen: false).clearSellerAuthorHouse();
    Provider.of<SearchProductController>(context, listen: false).getAuthorList(widget.sellerId);
    Provider.of<SearchProductController>(context, listen: false).getPublishingHouseList(widget.sellerId);
    Provider.of<SearchProductController>(context, listen: false).setProductTypeIndex(0, false);
    Provider.of<ShopController>(context, listen: false).setShopName(widget.name, notify: false);
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        Provider.of<SellerProductController>(context, listen: false).clearSellerProducts();
        Provider.of<CategoryController>(Get.context!, listen: false).onUpdateFilteredCategoryList(isSeller: false);
        Provider.of<BrandController>(Get.context!, listen: false).onUpdateFiltererBrandList(isSeller: false);
        Provider.of<ShopController>(Get.context!, listen: false).nullShopInfoModel();
        Provider.of<CategoryController>(Get.context!, listen: false).uncheckSellerCategoryList();
        Provider.of<BrandController>(Get.context!, listen: false).uncheckSellerBrandList();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: CustomAppBar(title: widget.name),
          body: Consumer<ShopController>(
              builder: (context, sellerProvider, _) {
                return CustomScrollView(
                    controller: _scrollController, slivers: [
                  SliverToBoxAdapter(
                    child: ShopInfoWidget(
                      vacationIsOn: vacationIsOn,
                      sellerName: widget.name ?? "",
                      sellerId: widget.sellerId!,
                      banner: widget.banner ?? '',
                      shopImage: widget.image ?? '',
                      temporaryClose: widget.temporaryClose!,
                      totalReview: widget.totalReview,
                      totalProduct: widget.totalProduct,
                      rating: widget.rating,
                      fromMore: widget.fromMore,
                      vacationDurationType: widget.vacationDurationType,
                      vacationEndDate: widget.vacationEndDate,
                      vacationStartDate: widget.vacationStartDate,
                    )
                  ),

                  SliverPersistentHeader(pinned: true,
                    delegate: SliverDelegate(
                      height: sellerProvider.shopMenuIndex == 1 ? 140 : 64,
                      child: Container(color: Theme.of(context).canvasColor.withValues(alpha: .94),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                            Expanded(child: Container(height: 48,
                              margin: const EdgeInsetsDirectional.only(start: 16, end: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: .9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppPalette.glassBorder(context)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: TabBar(physics: const NeverScrollableScrollPhysics(),
                                  isScrollable: false,
                                  dividerColor: Colors.transparent,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(14)),
                                  splashBorderRadius: BorderRadius.circular(14),
                                  padding: const EdgeInsets.all(0),
                                  controller: _tabController,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Theme.of(context).hintColor,
                                  onTap: (value){
                                    sellerProvider.setMenuItemIndex(value);
                                    searchController.clear();},
                                  unselectedLabelStyle: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  labelStyle: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  tabs: [
                                    Tab(text: getTranslated("overview", context)),
                                    Tab(text: getTranslated("all_products", context)),
                                  ],
                                ),
                              ),
                            ),
                            ),



                            if(sellerProvider.shopMenuIndex == 1)
                              Stack(
                                children: [
                                  Padding(padding:  EdgeInsets.only(right: Provider.of<LocalizationController>(context, listen: false).isLtr ?Dimensions.paddingSizeDefault: 0,
                                    left: Provider.of<LocalizationController>(context, listen: false).isLtr ? 0 : Dimensions.paddingSizeDefault),
                                    child: InkWell(onTap: () => showModalBottomSheet(context: context,
                                      isScrollControlled: true, backgroundColor: Colors.transparent,
                                      builder: (c) =>  ProductFilterDialog(sellerId: widget.sellerId!)),

                                      child: Container(decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.35)),
                                        borderRadius: BorderRadius.circular(14)),
                                        width: 48,height: 48,
                                        child: Icon(Icons.tune_rounded, size: 20, color: Theme.of(context).primaryColor)))
                                  ),

                                  Consumer<SellerProductController>(
                                    builder: (context, sellerProductController, _) {
                                      return sellerProductController.isFilterApply ?
                                        CircleAvatar(radius: 5, backgroundColor: Theme.of(context).primaryColor) :
                                        SizedBox();
                                    }
                                  )
                                ],
                              ),
                          ]),


                          if(sellerProvider.shopMenuIndex == 1)
                            Container(
                              color: Theme.of(context).canvasColor,
                              child: SearchWidget(hintText: '${getTranslated('search_hint', context)}', sellerId: widget.sellerId!)
                            )]
                        )
                      )
                    )
                  ),

                  SliverToBoxAdapter(
                    child: sellerProvider.shopMenuIndex == 0 ? ShopOverviewScreen(sellerId: widget.sellerId!, scrollController: _scrollController) :
                    Padding(
                      padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeSmall,  Dimensions.paddingSizeSmall,  Dimensions.paddingSizeSmall, 0),
                      child: ShopProductViewList(scrollController: _scrollController, sellerId: widget.sellerId!)
                    )
                  ),

                ]);
              }
          )
      ),
    );
  }
}
