import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_asset_image_widget.dart';
import 'package:kk_thotix_m3aak/features/shop/domain/models/seller_model.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/shop_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SellerCard extends StatefulWidget {
  final Seller? sellerModel;
  final bool isHomePage;
  final int index;
  final int length;
  const SellerCard({super.key, this.sellerModel, this.isHomePage = false, required this.index, required this.length});

  @override
  State<SellerCard> createState() => _SellerCardState();
}

class _SellerCardState extends State<SellerCard> {
  bool vacationIsOn = false;
  @override
  Widget build(BuildContext context) {
    var splashController = Provider.of<SplashController>(context, listen: false);

    vacationIsOn = ShopHelper.isVacationActive(
      context,
      startDate: widget.sellerModel?.shop?.vacationStartDate,
      endDate: widget.sellerModel?.shop?.vacationEndDate,
      vacationDurationType: widget.sellerModel?.shop?.vacationDurationType,
      vacationStatus: widget.sellerModel?.shop?.vacationStatus,
      isInHouseSeller: widget.sellerModel?.id == 0,
    );


    return InkWell(
        onTap: () {
          RouterHelper.getTopSellerRoute (
            action: RouteAction.push,
            sellerId: widget.sellerModel?.id,
            temporaryClose: widget.sellerModel?.shop?.temporaryClose,
            vacationStatus: widget.sellerModel?.shop?.vacationStatus??false,
            vacationEndDate: widget.sellerModel?.shop?.vacationEndDate,
            vacationStartDate: widget.sellerModel?.shop?.vacationStartDate,
            vacationDurationType: widget.sellerModel?.shop?.vacationDurationType,
            name: widget.sellerModel?.shop?.name,
            banner: widget.sellerModel?.shop?.bannerFullUrl?.path,
            image: widget.sellerModel?.shop?.imageFullUrl?.path,
            totalProduct: widget.sellerModel?.productCount,
            totalReview: widget.sellerModel?.ratingCount,
            rating: widget.sellerModel?.averageRating?.toString(),
          );
        },
        child : Padding(
          padding : widget.isHomePage?
          EdgeInsets.only(
            left : widget.index == 0 ? Dimensions.paddingSizeSmall :
            Provider.of<LocalizationController>(context, listen: false).isLtr ?
            Dimensions.paddingSizeSmall : 0,
            right: widget.index + 1 == widget.length ?
            Dimensions.paddingSizeSmall : (Provider.of<LocalizationController>(context, listen: false).isLtr && widget.isHomePage) ?
            0 : Dimensions.paddingSizeSmall,
            bottom: Dimensions.paddingSizeExtraSmall
          ) : const EdgeInsets.fromLTRB( Dimensions.paddingSizeSmall,  Dimensions.paddingSizeDefault,  Dimensions.paddingSizeSmall,0),

          child: widget.isHomePage ? _HomeSellerCard(seller: widget.sellerModel!, closed: (widget.sellerModel!.shop?.temporaryClose ?? false) || vacationIsOn) : Container(clipBehavior: Clip.none, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .08)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ]),
            child: Stack(
              children: [
                Column(children: [
                  SizedBox(
                    height: widget.isHomePage ? 64 : 84,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: CustomImageWidget(image: widget.sellerModel?.id == 0 ?
                      splashController.configModel?.inHouseShop?.bannerFullUrl?.path ?? '' :
                      widget.sellerModel!.shop!.bannerFullUrl?.path ?? ''))
                  ),

                  Expanded(
                    child: Row(children: [
                      const SizedBox(width : Dimensions.iconSizeExtraLarge + Dimensions.paddingSizeLarge + Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, right: Dimensions.paddingSizeSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text( widget.sellerModel?.id == 0
                                  ? splashController.configModel?.inHouseShop?.name ?? ''
                                  : widget.sellerModel?.shop?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textMedium.copyWith(
                                  height: 1.1,
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomAssetImageWidget(Images.shopLocationIcon, height: 12, width: 12),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Expanded(
                                    child: Text(
                                      "${widget.sellerModel?.shop?.address}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),

                  Padding(padding: EdgeInsets.only(
                      left: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      bottom: widget.isHomePage ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),
                      child: Row( children: [

                        if((widget.sellerModel?.ratingCount ?? 0) > 0)
                          ...[
                            Expanded(child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE3F6F2),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Center(
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.star_rate_rounded, color: Colors.yellow.shade700, size: 15),
                                
                                  Text("${widget.sellerModel?.averageRating?.toStringAsFixed(1)} ", style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  )),
                                
                                  Text(" (${widget.sellerModel?.ratingCount??0})", style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                  )),
                                ]),
                              ),
                            ),
                            ),
                            SizedBox(width: Dimensions.paddingSizeSmall),
                          ],

                        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            decoration: BoxDecoration(color: const Color(0xFFD7F4EE),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(NumberFormat.compact().format(widget.sellerModel?.productCount??0),
                                style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF0E9F8E)),),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text("${getTranslated('products', context)}", style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)
                              )]))
                        )
                      ])
                  ),


                ]),


                PositionedDirectional(
                  top: widget.isHomePage ? (64-22) : (84-22),
                  start: 10,
                  child: Stack(children: [
                    Container(width: 64,height: 64,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeOverLarge)),
                          color: Theme.of(context).highlightColor,
                          border: Border.all(color: Theme.of(context).cardColor, width: 2.5)),
                      child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeOverLarge)),
                        child: CustomImageWidget(
                          image: widget.sellerModel!.id == 0 ?
                          splashController.configModel!.inHouseShop?.imageFullUrl?.path ?? '' :
                          '${widget.sellerModel!.shop?.imageFullUrl?.path}',
                          width: 64,height: 64,
                        ),
                      ),
                    ),

                    if((widget.sellerModel!.shop!.temporaryClose ?? false) || vacationIsOn)
                      Container(width: 64,height: 64,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha:.5),
                        shape: BoxShape.circle,
                        // borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall))
                        )
                      ),

                    (widget.sellerModel!.shop!.temporaryClose ?? false) ?
                    SizedBox(width: 64,height: 64,
                      child: Center(child: Text(getTranslated('temporary_closed', context)!, textAlign: TextAlign.center, style: textRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ))),
                    ) :
                    vacationIsOn == true ?
                    SizedBox(width: 64,height: 64,
                      child: Center(child: Text(getTranslated('close_for_now', context)!, textAlign: TextAlign.center, style: textRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ))),
                    ) : const SizedBox(),
                  ])
                )


              ],
            ),
          ),
        )
    );
  }
}

/// Compact store card used in the home carousel.
class _HomeSellerCard extends StatelessWidget {
  const _HomeSellerCard({required this.seller, required this.closed});
  final Seller seller;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<SplashController>(context, listen: false).configModel;
    final bool inHouse = seller.id == 0;
    final String name = inHouse ? config?.inHouseShop?.name ?? '' : seller.shop?.name ?? '';
    final String logo = inHouse ? config?.inHouseShop?.imageFullUrl?.path ?? '' : '${seller.shop?.imageFullUrl?.path}';
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    Widget stat(IconData icon, Color color, String value, String label) => Expanded(
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(value, style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor)),
          const SizedBox(width: 3),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))),
        ]),
      ),
    );

    return GlassContainer(
      blur: false,
      radius: 22,
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(18)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(fit: StackFit.expand, children: [
                Container(color: Theme.of(context).cardColor, child: CustomImageWidget(image: logo, fit: BoxFit.cover)),
                if (closed)
                  Container(
                    color: Colors.black.withValues(alpha: .55),
                    alignment: Alignment.center,
                    child: Text(
                      getTranslated((seller.shop?.temporaryClose ?? false) ? 'temporary_closed' : 'close_for_now', context) ?? '',
                      textAlign: TextAlign.center,
                      style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).primaryColor),
              const SizedBox(width: 3),
              Expanded(child: Text(seller.shop?.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))),
            ]),
          ])),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor, textDirection: Directionality.of(context)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          if ((seller.ratingCount ?? 0) > 0) ...[
            stat(Icons.star_rounded, AppPalette.warning, seller.averageRating?.toStringAsFixed(1) ?? '0', '(${seller.ratingCount})'),
            const SizedBox(width: 8),
          ],
          stat(Icons.medication_outlined, AppPalette.primary, NumberFormat.compact().format(seller.productCount ?? 0),
              getTranslated('products', context) ?? ''),
        ]),
      ]),
    );
  }
}
