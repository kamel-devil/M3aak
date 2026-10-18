
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/chat/controllers/chat_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/domain/enums/vacation_duration_type.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/controllers/shop_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';

class ShopInfoWidget extends StatelessWidget {
  final bool vacationIsOn;
  final bool temporaryClose;
  final String sellerName;
  final int sellerId;
  final int? totalReview;
  final int? totalProduct;
  final String? rating;
  final String banner;
  final String shopImage;
  final DateTime? vacationEndDate;
  final DateTime? vacationStartDate;
  final VacationDurationType? vacationDurationType;
  final bool fromMore;
  const ShopInfoWidget({super.key, required this.vacationIsOn, required this.sellerName,
    required this.sellerId, required this.banner, required this.shopImage, required this.temporaryClose, this.totalReview, this.totalProduct, this.rating, this.vacationEndDate, this.vacationStartDate, this.vacationDurationType, required this.fromMore});

  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final String logo = sellerId == 0 ? splashController.configModel?.inHouseShop?.imageFullUrl?.path ?? '' : shopImage;

    void openChat() {
      if (temporaryClose) {
        showCustomSnackBar("${getTranslated("this_shop_is_close_now", context)}", context);
      } else if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
        showModalBottomSheet(context: context, builder: (_) => NotLoggedInBottomSheetWidget(
          fromPage: RouterHelper.topSellerScreen,
          onLoginSuccess: () {
            RouterHelper.getTopSellerRoute(
              action: RouteAction.pushReplacement,
              sellerId: sellerId,
              temporaryClose: temporaryClose,
              vacationStatus: vacationIsOn,
              vacationEndDate: vacationEndDate,
              vacationStartDate: vacationStartDate,
              vacationDurationType: vacationDurationType,
              name: sellerName,
              banner: banner,
              image: shopImage,
              fromMore: fromMore,
              totalReview: totalReview,
              totalProduct: totalProduct,
            );
          },
        ));
      } else {
        Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
        RouterHelper.getChatScreenRoute(
          action: RouteAction.push,
          id: sellerId,
          name: sellerName,
          userType: 1,
          isShopOnVacation: vacationIsOn,
          image: logo,
        );
      }
    }

    Widget stat(String value, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(color: AppPalette.tint(context), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value,
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor))),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1, color: Theme.of(context).hintColor)),
        ]),
      ),
    );

    return Column(children: [
      SizedBox(
        height: (ResponsiveHelper.isTab(context) ? 250 : 170) + MediaQuery.of(context).padding.top,
        width: double.infinity,
        child: Stack(fit: StackFit.expand, children: [
          Container(
            decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
            child: CustomImageWidget(
              image: sellerId == 0 ? splashController.configModel?.inHouseShop?.bannerFullUrl?.path ?? '' : banner,
              placeholder: Images.placeholder_3x1,
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: .25), Colors.transparent],
          ))),
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 12,
            start: 16,
            child: IconButton(
              tooltip: getTranslated('back', context),
              onPressed: () => Navigator.of(context).maybePop(),
              style: IconButton.styleFrom(
                minimumSize: const Size(44, 44),
                backgroundColor: Theme.of(context).cardColor.withValues(alpha: .92),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
            ),
          ),
        ]),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          transform: Matrix4.translationValues(0, -48, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppPalette.glassBorder(context)),
            boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .12), blurRadius: 30, offset: const Offset(0, 14))],
          ),
          child: Consumer<ShopController>(builder: (context, sellerProvider, _) {
            final info = sellerProvider.sellerInfoModel;
            final double avg = double.tryParse(rating ?? info?.avgRating?.toString() ?? '0') ?? 0;
            final int reviews = totalReview ?? info?.totalReview ?? 0;
            final int products = totalProduct ?? info?.totalProduct ?? 0;
            final double minOrder = (info?.minimumOrderAmount ?? 0).toDouble();

            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(
                  width: 66,
                  height: 66,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(21)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Stack(fit: StackFit.expand, children: [
                      Container(color: Theme.of(context).cardColor,
                          child: CustomImageWidget(image: logo, fit: BoxFit.cover, placeholder: Images.pharmacyIcon)),
                      if (temporaryClose || vacationIsOn)
                        Container(
                          color: Colors.black.withValues(alpha: .55),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(2),
                          child: Text(getTranslated(temporaryClose ? 'temporary_closed' : 'close_for_now', context) ?? '',
                              textAlign: TextAlign.center,
                              style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sellerName, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: textColor)),
                  if (minOrder > 0)
                    Text('${getTranslated('minimum_order', context)}: ${PriceConverter.convertPrice(context, minOrder)}',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                ])),
                IconButton(
                  tooltip: getTranslated('chat_with_store', context),
                  onPressed: openChat,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor: AppPalette.tint(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppPalette.glassBorder(context)),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppPalette.primaryDeep, size: 19),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                stat(avg.toStringAsFixed(1), getTranslated('rating', context) ?? ''),
                const SizedBox(width: 8),
                stat(NumberFormat.compact().format(products), getTranslated('products', context) ?? ''),
                const SizedBox(width: 8),
                stat('$reviews', getTranslated('reviews', context) ?? ''),
              ]),
            ]);
          }),
        ),
      ),
    ]);
  }
}
