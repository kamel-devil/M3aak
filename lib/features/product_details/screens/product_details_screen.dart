import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/deal/controllers/flash_deal_controller.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/seller_product_controller.dart';
import 'package:kk_thotix_m3aak/features/product_details/controllers/product_details_controller.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/bottom_cart_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/product_image_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/product_specification_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/product_title_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/promise_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/related_product_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/review_and_specification_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/shop_info_widget.dart';
import 'package:kk_thotix_m3aak/features/review/controllers/review_controller.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/product_details_shimmer.dart';
import 'package:kk_thotix_m3aak/features/review/widgets/review_section.dart';
import 'package:kk_thotix_m3aak/features/shop/controllers/shop_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/widgets/shop_more_product_view_list.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/product_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/title_row_widget.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  final int? productId;
  final String? slug;
  final bool isFromWishList;
  final bool isNotification;
  final bool fromFlashDeals;
  const ProductDetails({super.key, required this.productId, required this.slug, this.isFromWishList = false, this.isNotification = false, this.fromFlashDeals = false});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {

  List<TextSpan> _publishingHouse = [];
  List<TextSpan> _authors = [];

  Size widgetSize = const Size(100, 400);

  Future<void> _loadData( BuildContext context) async {
    Provider.of<ProductDetailsController>(context, listen: false).getProductDetails(context, widget.productId.toString(), widget.slug.toString());
    Provider.of<ReviewController>(context, listen: false).removePrevReview();
    Provider.of<ProductDetailsController>(context, listen: false).removePrevLink();
    Provider.of<ReviewController>(context, listen: false).getReviewList(widget.productId, widget.slug, context);
    Provider.of<ProductController>(context, listen: false).removePrevRelatedProduct();
    Provider.of<ProductController>(context, listen: false).initRelatedProductList(widget.productId.toString(), context);
    Provider.of<ProductDetailsController>(context, listen: false).getCount(widget.productId.toString(), context);
    Provider.of<ProductDetailsController>(context, listen: false).getSharableLink(widget.slug.toString(), context);
    Provider.of<ProductDetailsController>(context, listen: false).setImageSliderSelectedIndex(0, isUpdate: false);
    Provider.of<ShopController>(context, listen: false).emptyProductDetailsSeller();
  }

  @override
  void initState() {
    Provider.of<ProductDetailsController>(context, listen: false).selectReviewSection(false, isUpdate: false);
    _loadData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        if(widget.isNotification) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: getTranslated('product_details', context),
          showResetIcon: true,
          reset: Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Consumer<ProductDetailsController>(builder: (context, details, _) => IconButton(
              tooltip: getTranslated('share', context),
              onPressed: details.sharableLink == null ? null
                  : () => SharePlus.instance.share(ShareParams(text: details.sharableLink!)),
              style: IconButton.styleFrom(
                minimumSize: const Size(44, 44),
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: AppPalette.glassBorder(context)),
                ),
              ),
              icon: Icon(Icons.ios_share_rounded, size: 19, color: Theme.of(context).textTheme.bodyLarge?.color),
            )),
          ),
          onBackPressed: () {
            if(Navigator.of(context).canPop()){
              Navigator.of(context).pop();
            }else {
              RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
            }
          },
        ),

        body: RefreshIndicator(
          onRefresh: () async => _loadData(context),
          child: Consumer<ProductDetailsController>(
            builder: (context, details, child) {
              if(details.productDetailsModel?.publishingHouse != null && details.productDetailsModel!.publishingHouse!.isNotEmpty) {
                _publishingHouse = [];
                for(String? houseName in details.productDetailsModel!.publishingHouse!) {
                  _publishingHouse.add(TextSpan(text: '${houseName!} ' , style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)));
                }
              }

              if(details.productDetailsModel?.authors != null && details.productDetailsModel!.authors!.isNotEmpty) {
                _authors = [];
                for(String? authorName in details.productDetailsModel!.authors!) {
                  _authors.add(TextSpan(text: '${authorName!} ', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)));
                }
              }


              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 110),
                child: !details.isDetails ?
                Column(children: [

                  if(widget.fromFlashDeals)
                  Consumer<FlashDealController>(
                    builder: (context, flashDealController, child) {
                      Duration? eventDuration = flashDealController.duration;

                      int? days, hours, minutes, seconds;
                      if (eventDuration != null) {
                        days = eventDuration.inDays;
                        hours = eventDuration.inHours - days * 24;
                        minutes = eventDuration.inMinutes - (24 * days * 60) - (hours * 60);
                        seconds = eventDuration.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
                      }

                      return  Padding(
                        padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: Text(
                                    getTranslated('this_product_is_now_on_a_flash_deal', context) ?? '',
                                    style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).textTheme.bodyLarge?.color
                                    ),
                                  ),
                                ),
                              ),


                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                eventDuration == null ? const Expanded(child: SizedBox.shrink()) :
                                Padding(padding: const EdgeInsets.symmetric(vertical: 0),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const SizedBox(width: 5),
                                    TimerBox(time: days, day: getTranslated('day', context), isDetailsPage: true),

                                    TimerBox(time: hours, day: getTranslated('hour', context), isDetailsPage:  true),

                                    TimerBox(time: minutes, day: getTranslated('min', context), isDetailsPage:  true),

                                    TimerBox(time: seconds,day: getTranslated('sec', context), isDetailsPage:  true),
                                  ]),
                                ),
                              ])
                            ],
                          ),
                        ),
                      );
                    }
                  ),

                  ProductImageWidget(productModel: details.productDetailsModel, fromFlashDeals: widget.fromFlashDeals),

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ProductTitleWidget(
                      productModel: details.productDetailsModel,
                      averageRatting: details.productDetailsModel?.averageReview ?? "0",
                    ),

                    (details.productDetailsModel?.productType == 'digital' && (_publishingHouse.isNotEmpty || _authors.isNotEmpty)) ?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal : Dimensions.homePagePadding),
                      child: RichText(text: TextSpan(
                          text: '',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          children: [
                            if (details.productDetailsModel?.publishingHouse != null && details.productDetailsModel!.publishingHouse!.isNotEmpty)
                              TextSpan( text: "${getTranslated('publishing_housec', context)}", style: titilliumRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).hintColor,
                              )),

                            ..._publishingHouse,

                            if (details.productDetailsModel?.publishingHouse != null && details.productDetailsModel!.publishingHouse!.isNotEmpty)
                              WidgetSpan(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                  height: 15.0, width: 1.0,
                                  color: Theme.of(context).primaryColor.withValues(alpha:0.50),
                                ),
                              ),

                            if (details.productDetailsModel?.authors != null && details.productDetailsModel!.authors!.isNotEmpty)
                              TextSpan( text: "${getTranslated('author', context)}",
                                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)
                              ),
                            ..._authors,
                          ],
                      )),
                    ) : const SizedBox(),

                    Builder(builder: (context) {
                      final bool hasDetails = details.productDetailsModel?.details != null && details.productDetailsModel!.details!.isNotEmpty;
                      final bool hasReviews = (double.tryParse(details.productDetailsModel?.averageReview ?? '0') ?? 0) > 0;
                      if (!hasDetails && !hasReviews) return const SizedBox(height: 4);
                      return GlassContainer(
                        blur: false,
                        radius: 26,
                        margin: const EdgeInsets.fromLTRB(Dimensions.homePagePadding, 14, Dimensions.homePagePadding, 0),
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          ReviewAndSpecificationSectionWidget(
                            averageReview: double.tryParse(details.productDetailsModel?.averageReview ?? '0'),
                          ),
                          const SizedBox(height: 12),
                          if (details.isReviewSelected && hasReviews)
                            ReviewSection(details: details)
                          else if (hasDetails)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ProductSpecificationWidget(
                                productSpecification: ProductHelper.removeIframe(details.productDetailsModel!.details ?? ''),
                              ),
                            ),
                        ]),
                      );
                    }),

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // (details.productDetailsModel?.videoUrl != null && details.isValidYouTubeUrl(details.productDetailsModel!.videoUrl!))?
                      // YoutubeVideoWidget(url: details.productDetailsModel!.videoUrl) : const SizedBox(),

                      (details.productDetailsModel != null) ?
                      ShopInfoWidget(sellerId: details.productDetailsModel!.addedBy == 'seller'? details.productDetailsModel!.userId.toString() : "0") : const SizedBox.shrink(),
                      const SizedBox(height: 14),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                        child: PromiseWidget(),
                      ),

                      _ProductDetailsProductListWidget(scrollController: scrollController),


                    ]),
                  ]),
                ]) :
                const ProductDetailsShimmer(),
              );
            },
          ),
        ),

        extendBody: true,
        bottomNavigationBar: Consumer<ProductDetailsController>(
          builder: (context, details, child) {
            return !details.isDetails?
            BottomCartWidget(product: details.productDetailsModel):const SizedBox();
          }
        ),
      ),
    );
  }
}

class _ProductDetailsProductListWidget extends StatelessWidget {
  const _ProductDetailsProductListWidget({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsController>(
        builder: (context, productDetailsController, _) {
          return Column(children: [

            const SizedBox(height: Dimensions.paddingSizeSmall),

            Consumer<ProductController>(
                builder: (context, productController,_) {
                  return (productController.relatedProductList != null && productController.relatedProductList!.isNotEmpty)?Padding(padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall),
                    child: TitleRowWidget(title: getTranslated('related_products', context), isDetailsPage: true)): const SizedBox();
                }
            ),
            const SizedBox(height: 5),
            const RelatedProductWidget(),


            Consumer<SellerProductController>(
                builder: (context, sellerProductController, _) {
                  return (sellerProductController.sellerMoreProduct != null && sellerProductController.sellerMoreProduct!.products != null &&
                      sellerProductController.sellerMoreProduct!.products!.isNotEmpty)?
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault),
                    child: TitleRowWidget(title: getTranslated('more_from_the_shop', context),
                      onTap: () {
                        if(productDetailsController.productDetailsModel?.addedBy == 'seller') {
                          RouterHelper.getTopSellerRoute(
                            action: RouteAction.push,
                            sellerId: productDetailsController.productDetailsModel?.seller?.id,
                            temporaryClose: productDetailsController.productDetailsModel?.seller?.shop?.temporaryClose,
                            vacationStatus: productDetailsController.productDetailsModel?.seller?.shop?.vacationStatus ?? false,
                            vacationEndDate: productDetailsController.productDetailsModel?.seller?.shop?.vacationEndDate,
                            vacationStartDate: productDetailsController.productDetailsModel?.seller?.shop?.vacationStartDate,
                            vacationDurationType: productDetailsController.productDetailsModel?.seller?.shop!.vacationDurationType,
                            name: productDetailsController.productDetailsModel?.seller?.shop?.name,
                            banner: productDetailsController.productDetailsModel?.seller?.shop?.bannerFullUrl?.path,
                            image: productDetailsController.productDetailsModel?.seller?.shop?.imageFullUrl?.path,
                            fromMore: true,
                          );
                        } else {
                          RouterHelper.getTopSellerRoute(
                            sellerId: 0,
                            fromMore: true,
                            temporaryClose: Provider.of<SplashController>(context, listen: false).configModel?.inhouseTemporaryClose?.status ?? false,
                            vacationStatus: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.status,
                            vacationEndDate: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.vacationEndDate,
                            vacationStartDate: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.vacationStartDate,
                            vacationDurationType: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.vacationDurationType,
                            name: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name,
                            banner: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.bannerFullUrl?.path,
                            image: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.imageFullUrl?.path
                          );
                        }
                      },

                    ),
                  ) : const SizedBox();
                }
            ),

            Padding(padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall),
              child: ShopMoreProductViewList(
              scrollController: scrollController, sellerId: productDetailsController.productDetailsModel!.userId!)
            ),



          ]);
        }
    );
  }
}
