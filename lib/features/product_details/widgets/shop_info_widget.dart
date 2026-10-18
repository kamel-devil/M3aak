import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/chat/controllers/chat_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/helper/shop_helper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/controllers/shop_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Store card: logo, name, rating and product count, chat and visit actions.
class ShopInfoWidget extends StatefulWidget {
  final String sellerId;
  const ShopInfoWidget({super.key, required this.sellerId});

  @override
  State<ShopInfoWidget> createState() => _ShopInfoWidgetState();
}

class _ShopInfoWidgetState extends State<ShopInfoWidget> {
  @override
  void initState() {
    Provider.of<ShopController>(context, listen: false).getSellerInfoProductDetails(widget.sellerId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<SplashController>(context, listen: false).configModel;

    return Consumer<ShopController>(
      builder: (context, seller, child) {
        final info = seller.sellerInfoModelProductDetails;
        if (info == null) return const SizedBox();

        final shop = info.seller?.shop;
        final bool inHouse = info.seller == null;
        final bool isVacationActive = ShopHelper.isVacationActive(
          context,
          startDate: shop?.vacationStartDate,
          endDate: shop?.vacationEndDate,
          vacationDurationType: shop?.vacationDurationType,
          vacationStatus: shop?.vacationStatus,
          isInHouseSeller: widget.sellerId == '0',
        );
        final bool closed = isVacationActive || (shop?.temporaryClose ?? false);

        String name = (inHouse ? config?.inHouseShop?.name : shop?.name) ?? '';
        if (name.trim().isEmpty) name = config?.inHouseShop?.name ?? '';
        if (name.trim().isEmpty) name = AppConstants.appName;
        final String logo = inHouse ? '${config?.inHouseShop?.imageFullUrl?.path}' : '${shop?.imageFullUrl?.path}';
        final double rating = double.tryParse(info.avgRating ?? '0') ?? 0;
        final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

        void openStore() {
          if (!inHouse) {
            RouterHelper.getTopSellerRoute(
              action: RouteAction.push,
              sellerId: info.seller?.id,
              temporaryClose: shop?.temporaryClose ?? false,
              vacationStatus: shop?.vacationStatus ?? false,
              vacationEndDate: shop?.vacationEndDate,
              vacationStartDate: shop?.vacationStartDate,
              vacationDurationType: shop?.vacationDurationType,
              name: shop?.name,
              banner: shop?.bannerFullUrl?.path,
              image: shop?.imageFullUrl?.path,
            );
          } else {
            RouterHelper.getTopSellerRoute(
              action: RouteAction.push,
              sellerId: 0,
              temporaryClose: config?.inhouseTemporaryClose?.status ?? false,
              vacationStatus: config?.inhouseVacationAdd?.status,
              vacationEndDate: config?.inhouseVacationAdd?.vacationEndDate,
              vacationStartDate: config?.inhouseVacationAdd?.vacationStartDate,
              vacationDurationType: config?.inhouseVacationAdd?.vacationDurationType,
              name: config?.inHouseShop?.name,
              banner: config?.inHouseShop?.bannerFullUrl?.path,
              image: config?.inHouseShop?.imageFullUrl?.path,
            );
          }
        }

        void openChat() {
          if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
            showModalBottomSheet(context: context, builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.productDetailsScreen));
          } else if (shop?.temporaryClose ?? false) {
            showCustomSnackBar("${getTranslated("this_shop_is_close_now", context)}", context);
          } else {
            Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
            if (!inHouse) {
              RouterHelper.getChatScreenRoute(
                action: RouteAction.push,
                id: info.seller?.id,
                name: shop?.name ?? '',
                userType: 1,
                image: shop?.imageFullUrl?.path ?? '',
                isShopOnVacation: isVacationActive,
                isShopTemporaryClosed: shop?.temporaryClose ?? false,
              );
            } else {
              RouterHelper.getChatScreenRoute(
                action: RouteAction.push,
                id: 0,
                name: config?.inHouseShop?.name ?? '',
                userType: 1,
                image: "${config?.inHouseShop?.imageFullUrl?.path}",
                isShopOnVacation: isVacationActive,
                isShopTemporaryClosed: config?.inhouseTemporaryClose?.status ?? false,
              );
            }
          }
        }

        return GlassContainer(
          blur: false,
          radius: 26,
          margin: const EdgeInsets.fromLTRB(Dimensions.homePagePadding, 14, Dimensions.homePagePadding, 0),
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              InkWell(
                onTap: openStore,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(18)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(fit: StackFit.expand, children: [
                      Container(
                        color: Theme.of(context).cardColor,
                        child: CustomImageWidget(image: logo, fit: BoxFit.cover, placeholder: Images.pharmacyIcon),
                      ),
                      if (closed)
                        Container(
                          color: Colors.black.withValues(alpha: .55),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(2),
                          child: Text(getTranslated('close_for_now', context) ?? '', textAlign: TextAlign.center,
                              style: textRegular.copyWith(color: Colors.white, fontSize: 8)),
                        ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
                const SizedBox(height: 3),
                Wrap(spacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (rating > 0)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, size: 15, color: AppPalette.warning),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(1),
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
                      if ((info.totalReview ?? 0) > 0)
                        Text(' (${info.totalReview})',
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                    ]),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: NumberFormat.compact().format(info.totalProduct ?? 0),
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
                    TextSpan(text: ' ${getTranslated('products', context)}',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                  ])),
                ]),
              ])),
              const SizedBox(width: 8),
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
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppPalette.primaryDeep),
              ),
            ]),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: openStore,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                foregroundColor: AppPalette.primaryDeep,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.storefront_outlined, size: 19),
              label: Text(getTranslated('visit_store', context) ?? '',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: AppPalette.primaryDeep)),
            ),
          ]),
        );
      },
    );
  }
}
