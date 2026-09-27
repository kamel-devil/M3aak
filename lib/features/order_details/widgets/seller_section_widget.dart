import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_asset_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/chat/controllers/chat_controller.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/helper/shop_helper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

class SellerSectionWidget extends StatelessWidget {
  final OrderDetailsController? order;
  const SellerSectionWidget({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final hasOrderDetails = order?.orderDetails?.isNotEmpty ?? false;
    if (!hasOrderDetails) {
      return const SizedBox();
    }

    final firstOrderDetail = order!.orderDetails!.first;
    bool isVacationActive = false;

    if (firstOrderDetail.seller != null) {
      isVacationActive = ShopHelper.isVacationActive(
        context,
        startDate: firstOrderDetail.seller?.shop?.vacationStartDate,
        endDate: firstOrderDetail.seller?.shop?.vacationEndDate,
        vacationDurationType:
            firstOrderDetail.seller?.shop?.vacationDurationType,
        vacationStatus: firstOrderDetail.seller?.shop?.vacationStatus,
        isInHouseSeller: firstOrderDetail.order?.sellerIs == 'admin',
      );
    }

    return Container(
      color: Theme.of(context).highlightColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: InkWell(
            onTap: () {
              if (Provider.of<AuthController>(context, listen: false)
                  .isLoggedIn()) {
                Provider.of<ChatController>(context, listen: false)
                    .setUserTypeIndex(context, 1);
                if ((firstOrderDetail.seller != null &&
                    ((firstOrderDetail.seller?.shop?.temporaryClose ??
                        false)))) {
                  showCustomSnackBar(
                      "${getTranslated("this_shop_is_close_now", context)}",
                      context);
                } else if (firstOrderDetail.seller != null) {
                  RouterHelper.getChatScreenRoute(
                    action: RouteAction.push,
                    id: firstOrderDetail.order?.sellerIs == 'admin'
                        ? 0
                        : firstOrderDetail.seller!.id,
                    name: firstOrderDetail.order?.sellerIs == 'admin'
                        ? "${Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name}"
                        : firstOrderDetail.seller!.shop!.name,
                    image: firstOrderDetail.order?.sellerIs == 'admin'
                        ? "${Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.imageFullUrl?.path}"
                        : firstOrderDetail.seller?.imageFullUrl?.path,
                    isShopOnVacation: isVacationActive,
                    isShopTemporaryClosed:
                        firstOrderDetail.seller?.shop?.temporaryClose ?? false,
                  );
                } else {
                  showCustomSnackBar(
                      getTranslated('seller_not_available', context), context,
                      isToaster: true);
                }
              } else {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (_) => const NotLoggedInBottomSheetWidget());
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                Icon(Icons.storefront_outlined,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        (firstOrderDetail.order?.sellerIs == 'admin')
                            ? '${Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name}'
                            : '${firstOrderDetail.seller?.shop?.name ?? getTranslated('seller_not_available', context)}',
                        style: textRegular.copyWith())),
                const Spacer(),
                const SizedBox(
                    width: Dimensions.iconSizeDefault,
                    child: CustomAssetImageWidget(Images.storeChatIcon,
                        height: 20, width: 20))
              ]),
            ),
          ),
        ),
        Divider(
            thickness: .25,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.50)),
      ]),
    );
  }
}
