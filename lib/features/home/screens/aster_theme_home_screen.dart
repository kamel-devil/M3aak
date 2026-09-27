import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kk_thotix_m3aak/common/basewidget/title_row_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/widgets/banners_widget.dart';
import 'package:kk_thotix_m3aak/features/banner/widgets/single_banner_widget.dart';
import 'package:kk_thotix_m3aak/features/brand/controllers/brand_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/category/controllers/category_controller.dart';
import 'package:kk_thotix_m3aak/features/category/widgets/category_list_widget.dart';
import 'package:kk_thotix_m3aak/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:kk_thotix_m3aak/features/deal/controllers/featured_deal_controller.dart';
import 'package:kk_thotix_m3aak/features/deal/controllers/flash_deal_controller.dart';
import 'package:kk_thotix_m3aak/features/deal/widgets/featured_deal_list_widget.dart';
import 'package:kk_thotix_m3aak/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/order_again_shimmer.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/top_store_shimmer.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/announcement_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/find_what_you_need_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/home_v2_components.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/more_store_list_view_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/order_again_list_view_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/featured_product_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/just_for_you/just_for_you_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/product_list_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/product_type_popup_menu_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/search_home_page_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/top_seller_widget.dart';
import 'package:kk_thotix_m3aak/features/notification/controllers/notification_controller.dart';
import 'package:kk_thotix_m3aak/features/order/controllers/order_controller.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/seller_product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product/enums/product_type.dart';
import 'package:kk_thotix_m3aak/features/product/widgets/home_category_product_widget.dart';
import 'package:kk_thotix_m3aak/features/product/widgets/latest_product_list_widget.dart';
import 'package:kk_thotix_m3aak/features/product/widgets/recommended_product_widget.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/search_product/controllers/search_product_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/controllers/shop_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/widgets/more_store_list_view.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/color_resources.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

import '../../banner/widgets/footer_banner_slider_widget.dart';

class AsterThemeHomeScreen extends StatefulWidget {
  const AsterThemeHomeScreen({super.key});

  @override
  State<AsterThemeHomeScreen> createState() => _AsterThemeHomeScreenState();

  static Future<void> loadData(bool reload) async {
    final shopController =
        Provider.of<ShopController>(Get.context!, listen: false);
    final categoryController =
        Provider.of<CategoryController>(Get.context!, listen: false);
    final bannerController =
        Provider.of<BannerController>(Get.context!, listen: false);
    final productController =
        Provider.of<ProductController>(Get.context!, listen: false);
    final brandController =
        Provider.of<BrandController>(Get.context!, listen: false);
    final featuredDealController =
        Provider.of<FeaturedDealController>(Get.context!, listen: false);
    final notificationController =
        Provider.of<NotificationController>(Get.context!, listen: false);
    final cartController =
        Provider.of<CartController>(Get.context!, listen: false);
    final profileController =
        Provider.of<ProfileController>(Get.context!, listen: false);
    final sellerProductController =
        Provider.of<SellerProductController>(Get.context!, listen: false);
    final orderController =
        Provider.of<OrderController>(Get.context!, listen: false);
    final splashController =
        Provider.of<SplashController>(Get.context!, listen: false);

    splashController.initConfig(Get.context!, null, null);

    shopController.getAllSellerList(offset: 1, isUpdate: reload);

    cartController.getCartData(Get.context!);

    bannerController.getBannerList();

    categoryController.getCategoryList(reload);

    productController.getHomeCategoryProductList(reload);

    shopController.getTopSellerList(offset: 1, isUpdate: reload);

    brandController.getBrandList(offset: 1, isUpdate: reload);

    productController.getLatestProductList(1, isUpdate: false);
    productController.getSelectedProductModel(1, isUpdate: false);

    productController.getFeaturedProductModel(1, isUpdate: reload);

    featuredDealController.getFeaturedDealList();

    // productController.getLProductList('1', reload: reload);

    productController.getRecommendedProduct();

    productController.findWhatYouNeed();

    productController.getJustForYouProduct(1, isUpdate: reload);

    shopController.getMoreStore();

    productController.getClearanceAllProductList(1, isUpdate: reload);

    if (notificationController.notificationModel == null ||
        (notificationController.notificationModel != null &&
            notificationController.notificationModel!.notification!.isEmpty) ||
        reload) {
      notificationController.getNotificationList(1);
    }

    if (Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()) {
      if (profileController.userInfoModel == null) {
        profileController.getUserInfo(Get.context!);
      }

      sellerProductController.getShopAgainFromRecentStore();

      if (orderController.orderModel == null ||
          (orderController.orderModel != null &&
              orderController.orderModel!.orders!.isEmpty) ||
          reload) {
        orderController.getOrderList(1, 'delivered', type: 'reorder');
      }
    }
  }
}

class _AsterThemeHomeScreenState extends State<AsterThemeHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  static const bool _homeV2Enabled =
      bool.fromEnvironment('HOME_V2', defaultValue: true);

  Widget _wrapSection(
      {required Widget child,
      EdgeInsetsGeometry? margin,
      EdgeInsetsGeometry? padding}) {
    if (!_homeV2Enabled) {
      return child;
    }
    return HomeV2SectionCard(
      margin: margin ??
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );
  }

  Future<void> _scanBarcode() async {
    final code = await context.push<String>(RouterHelper.barcodeScanScreen);

    if (!mounted || code == null || code.isEmpty) {
      return;
    }

    RouterHelper.getSearchRoute(action: RouteAction.push);
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Provider.of<SearchProductController>(context, listen: false)
          .searchProductByBarcode(code);
    }
  }

  String _greetingText(BuildContext context) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return getTranslated('good_morning', context) ?? 'Good morning';
    }
    if (hour < 17) {
      return getTranslated('good_afternoon', context) ?? 'Good afternoon';
    }
    return getTranslated('good_evening', context) ?? 'Good evening';
  }

  String _displayName(BuildContext context) {
    final profile =
        Provider.of<ProfileController>(context, listen: false).userInfoModel;
    final first = profile?.fName?.trim();
    final name = profile?.name?.trim();

    if (first != null && first.isNotEmpty) {
      return first;
    }
    if (name != null && name.isNotEmpty) {
      return name.split(' ').first;
    }

    return getTranslated('there', context) ?? 'there';
  }

  String _headerCenterText(BuildContext context) {
    final greeting = _greetingText(context);
    final userName = _displayName(context);
    return '$greeting, $userName';
  }

  bool singleVendor = false;
  @override
  void initState() {
    super.initState();

    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel!
            .businessMode ==
        "single";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _homeV2Enabled
          ? const Color(0xFFF7F8FC)
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await AsterThemeHomeScreen.loadData(true);
          },
          child: CustomScrollView(controller: _scrollController, slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              centerTitle: false,
              automaticallyImplyLeading: false,
              backgroundColor: _homeV2Enabled
                  ? Colors.transparent
                  : Theme.of(context).highlightColor,
              titleSpacing: _homeV2Enabled
                  ? Dimensions.paddingSizeDefault
                  : NavigationToolbar.kMiddleSpacing,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: _homeV2Enabled ? 64 : kToolbarHeight,
              title: _homeV2Enabled
                  ? Container(
                      height: 56,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            ColorResources.getHeaderGradientStart(context),
                            ColorResources.getHeaderGradientMid(context),
                            ColorResources.getHeaderGradientEnd(context),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        border: Border.all(
                            color: ColorResources.getHeaderBorder(context)),
                        boxShadow: [
                          BoxShadow(
                            color: ColorResources.getHeaderShadow(context),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: Image.asset(Images.logoWithNameImage,
                                height: 28),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 74),
                            child: Text(
                              _headerCenterText(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textMedium.copyWith(
                                color: Colors.white.withValues(alpha: .96),
                                fontSize: Dimensions.fontSizeDefault,
                                letterSpacing: .15,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Consumer<NotificationController>(
                              builder: (context, notification, _) {
                                final hasAnyNotification = (notification
                                        .notificationModel
                                        ?.notification
                                        ?.isNotEmpty ??
                                    false);

                                return InkWell(
                                  onTap: () =>
                                      RouterHelper.getNotificationRoute(
                                          action: RouteAction.push),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: 36,
                                        width: 36,
                                        decoration: BoxDecoration(
                                          color: ColorResources
                                              .getHeaderIconSurface(context),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color: ColorResources
                                                  .getHeaderIconBorder(
                                                      context)),
                                        ),
                                        child: const Icon(
                                            Icons.notifications_none_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ),
                                      if (hasAnyNotification)
                                        Positioned(
                                          right: -1,
                                          top: -1,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: ColorResources
                                                  .getNotificationDot(context),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Image.asset(Images.logoWithNameImage, height: 35),
            ),

            SliverToBoxAdapter(
              child: Provider.of<SplashController>(context, listen: false)
                          .configModel!
                          .announcement!
                          .status ==
                      '1'
                  ? Consumer<SplashController>(
                      builder: (context, announcement, _) {
                        return (announcement.configModel!.announcement!
                                        .announcement !=
                                    null &&
                                announcement.onOff)
                            ? AnnouncementWidget(
                                announcement:
                                    announcement.configModel!.announcement)
                            : const SizedBox();
                      },
                    )
                  : const SizedBox(),
            ),

            // Search Button
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverDelegate(
                height: _homeV2Enabled ? 72 : 70,
                child: _homeV2Enabled
                    ? HomeV2StickySearchBar(
                        onSearchTap: () => RouterHelper.getSearchRoute(
                            action: RouteAction.push),
                        onFilterTap: () => RouterHelper.getSearchRoute(
                            action: RouteAction.push),
                        onScanTap: _scanBarcode,
                      )
                    : InkWell(
                        onTap: () => RouterHelper.getSearchRoute(
                            action: RouteAction.push),
                        child: const Hero(
                            tag: 'search',
                            child: Material(child: SearchHomePageWidget())),
                      ),
              ),
            ),

            SliverToBoxAdapter(
              child: _wrapSection(
                margin: _homeV2Enabled
                    ? const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault)
                    : EdgeInsets.zero,
                padding:
                    _homeV2Enabled ? const EdgeInsets.all(8) : EdgeInsets.zero,
                child: const BannersWidget(),
              ),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: _wrapSection(
                child: const CategoryListWidget(isHomePage: true),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: Consumer<FlashDealController>(
                  builder: (context, megaDeal, child) {
                return megaDeal.flashDeal != null
                    ? megaDeal.flashDealList.isNotEmpty
                        ? _wrapSection(
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: TitleRowWidget(
                                    title: getTranslated('flash_deal', context),
                                    eventDuration: megaDeal.flashDeal != null
                                        ? megaDeal.duration
                                        : null,
                                    onTap: () {
                                      RouterHelper
                                          .getFlashDealScreenViewRoute();
                                    },
                                    isFlash: true),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Text(
                                    getTranslated(
                                            'hurry_up_the_offer_is_limited_grab_while_it_lasts',
                                            context) ??
                                        '',
                                    textAlign: TextAlign.center,
                                    style: textRegular.copyWith(
                                        color: Provider.of<ThemeController>(
                                                    context,
                                                    listen: false)
                                                .darkTheme
                                            ? Theme.of(context).hintColor
                                            : Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeDefault)),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              const Padding(
                                padding: EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeDefault),
                                child: FlashDealsListWidget(),
                              ),
                            ]),
                          )
                        : const SizedBox.shrink()
                    : const FlashDealShimmer();
              }),
            ),

            SliverToBoxAdapter(
              child: Consumer<ProductController>(
                  builder: (context, productController, _) {
                return productController.findWhatYouNeedModel != null
                    ? (productController
                                    .findWhatYouNeedModel!.findWhatYouNeed !=
                                null &&
                            productController.findWhatYouNeedModel!
                                .findWhatYouNeed!.isNotEmpty)
                        ? _wrapSection(
                            child: Column(children: [
                              TitleRowWidget(
                                  title: getTranslated(
                                      'find_what_you_need', context)),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              SizedBox(
                                  height: ResponsiveHelper.isTab(context)
                                      ? 165
                                      : 155,
                                  child: const FindWhatYouNeedView()),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                            ]),
                          )
                        : const SizedBox()
                    : const FindWhatYouNeedShimmer();
              }),
            ),

            SliverToBoxAdapter(
              child: (Provider.of<AuthController>(context, listen: false)
                      .isLoggedIn())
                  ? Consumer<OrderController>(
                      builder: (context, orderProvider, _) {
                      return orderProvider.deliveredOrderModel != null
                          ? (orderProvider.deliveredOrderModel!.orders !=
                                      null &&
                                  orderProvider
                                      .deliveredOrderModel!.orders!.isNotEmpty)
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.paddingSizeDefault),
                                  child: OrderAgainView(),
                                )
                              : Consumer<BannerController>(
                                  builder: (context, bannerProvider, child) {
                                  return bannerProvider.sideBarBanner != null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .paddingSizeDefault),
                                          child: SingleBannersWidget(
                                              bannerModel:
                                                  bannerProvider.sideBarBanner,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1.2),
                                        )
                                      : const SizedBox();
                                })
                          : const OrderAgainShimmerShimmer();
                    })
                  : Consumer<BannerController>(
                      builder: (context, bannerProvider, child) {
                      return bannerProvider.sideBarBanner != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault),
                              child: SingleBannersWidget(
                                  bannerModel: bannerProvider.sideBarBanner,
                                  height:
                                      MediaQuery.of(context).size.width * 1.2),
                            )
                          : const SizedBox();
                    }),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            if (!singleVendor)
              SliverToBoxAdapter(
                child: Consumer<ShopController>(
                    builder: (context, shopController, _) {
                  return shopController.topSellerModel != null
                      ? (shopController.topSellerModel!.sellers != null &&
                              shopController
                                  .topSellerModel!.sellers!.isNotEmpty)
                          ? _wrapSection(
                              child: Column(children: [
                                TitleRowWidget(
                                    title: getTranslated('top_stores', context),
                                    onTap: () =>
                                        RouterHelper.getAllTopSellerRoute(
                                            action: RouteAction.push,
                                            title: 'top_stores')),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                SizedBox(
                                    height: ResponsiveHelper.isTab(context)
                                        ? 180
                                        : 165,
                                    child: const TopSellerWidget()),
                                const SizedBox(
                                    height: Dimensions.paddingSizeDefault),
                              ]),
                            )
                          : const SizedBox()
                      : const TopStoreShimmer();
                }),
              ),

            SliverToBoxAdapter(
              child: Consumer<FeaturedDealController>(
                builder: (context, featuredDealProvider, child) {
                  return featuredDealProvider.featuredDealProductList != null
                      ? featuredDealProvider.featuredDealProductList!.isNotEmpty
                          ? Stack(children: [
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 150,
                                  color: Provider.of<ThemeController>(context,
                                              listen: false)
                                          .darkTheme
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: .20)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: .125)),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeDefault),
                                  child: Column(children: [
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0,
                                            Dimensions.paddingSizeDefault,
                                            0,
                                            Dimensions.paddingSizeDefault),
                                        child: TitleRowWidget(
                                            title:
                                                '${getTranslated('featured_deals', context)}',
                                            onTap: () {
                                              RouterHelper
                                                  .getFeaturedDealScreenViewRoute();
                                            })),
                                    const FeaturedDealsListWidget()
                                  ]))
                            ])
                          : const SizedBox.shrink()
                      : const FindWhatYouNeedShimmer();
                },
              ),
            ),

            SliverToBoxAdapter(
              child: const ClearanceListWidget(),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: const FooterBannerSliderWidget(),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: const FeaturedProductWidget(),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: Consumer<BannerController>(
                  builder: (context, bannerProvider, child) {
                return bannerProvider.topSideBarBannerBottom != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault,
                            left: Dimensions.bannerPadding,
                            right: Dimensions.bannerPadding),
                        child: SingleBannersWidget(
                            bannerModel: bannerProvider.topSideBarBannerBottom,
                            height: MediaQuery.of(context).size.width * 1.2))
                    : const SizedBox();
              }),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        _homeV2Enabled ? 16 : Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
                child: Padding(
                    padding:
                        EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: RecommendedProductWidget(fromAsterTheme: true))),

            SliverToBoxAdapter(child: const LatestProductListWidget()),
            SliverToBoxAdapter(
                child: const SizedBox(height: Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: Consumer<BannerController>(
                  builder: (context, bannerProvider, child) {
                return bannerProvider.footerBannerList != null &&
                        bannerProvider.footerBannerList!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault,
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault),
                        child: SingleBannersWidget(
                            bannerModel: bannerProvider.footerBannerList![0],
                            height: MediaQuery.of(context).size.width * 0.5))
                    : const SizedBox();
              }),
            ),
            SliverToBoxAdapter(
                child: const SizedBox(height: Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: Selector<ProductController, ProductModel?>(
                selector: (ctx, productController) =>
                    productController.justForYouProductModel,
                builder: (context, justForYouProductModel, _) {
                  return (justForYouProductModel?.products?.isNotEmpty ?? false)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleRowWidget(
                              title: getTranslated('just_for_you', context),
                              onTap: () {
                                RouterHelper.getViewAllProductScreenRoute(
                                    productType: ProductType.justForYou,
                                    action: RouteAction.push);
                              },
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            JustForYouView(
                                productList: justForYouProductModel?.products),
                          ],
                        )
                      : const SizedBox();
                },
              ),
            ),
            SliverToBoxAdapter(
                child: const SizedBox(height: Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: Consumer<ShopController>(
                  builder: (context, moreStoreProvider, _) {
                return moreStoreProvider.moreStoreList.isNotEmpty
                    ? Column(children: [
                        TitleRowWidget(
                          title: getTranslated('more_store', context),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MoreStoreViewListView(
                                      title: getTranslated(
                                          'more_store', context)))),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        const MoreStoreView(isHome: true),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ])
                    : const SizedBox();
              }),
            ),
            SliverToBoxAdapter(
                child: const SizedBox(height: Dimensions.paddingSizeDefault)),

            const HomeCategoryProductWidget(isHomePage: true),
            SliverToBoxAdapter(
                child: const SizedBox(height: Dimensions.paddingSizeDefault)),

            SliverToBoxAdapter(
              child: Consumer<BannerController>(
                  builder: (context, footerBannerProvider, child) {
                return footerBannerProvider.mainSectionBanner != null
                    ? SingleBannersWidget(
                        bannerModel: footerBannerProvider.mainSectionBanner,
                        height: MediaQuery.of(context).size.width / 4,
                      )
                    : const SizedBox();
              }),
            ),

            SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                  height: _homeV2Enabled ? 64 : 70,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: _homeV2Enabled
                          ? const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault)
                          : EdgeInsets.zero,
                      decoration: _homeV2Enabled
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            )
                          : null,
                      child: const ProductPopupFilterWidget(),
                    ),
                  ),
                )),

            HomeProductListWidget(scrollController: _scrollController),
            if (_homeV2Enabled)
              const SliverToBoxAdapter(child: HomeV2SectionGap(size: 24)),
          ]),
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverDelegate({required this.child, this.height = 70});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
