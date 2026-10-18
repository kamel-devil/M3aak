import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
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

    final config = Provider.of<SplashController>(context, listen: false).configModel;
    String shopName = firstOrderDetail.order?.sellerIs == 'admin'
        ? (config?.inHouseShop?.name ?? '')
        : (firstOrderDetail.seller?.shop?.name ?? '');
    if (shopName.trim().isEmpty) shopName = config?.inHouseShop?.name ?? '';
    if (shopName.trim().isEmpty) shopName = AppConstants.appName;
    final int count = order!.orderDetails!.length;

    void openChat() {
      if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
        Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
        if ((firstOrderDetail.seller != null && ((firstOrderDetail.seller?.shop?.temporaryClose ?? false)))) {
          showCustomSnackBar("${getTranslated("this_shop_is_close_now", context)}", context);
        } else if (firstOrderDetail.seller != null) {
          RouterHelper.getChatScreenRoute(
            action: RouteAction.push,
            id: firstOrderDetail.order?.sellerIs == 'admin' ? 0 : firstOrderDetail.seller!.id,
            name: firstOrderDetail.order?.sellerIs == 'admin'
                ? "${config?.inHouseShop?.name}"
                : firstOrderDetail.seller!.shop!.name,
            image: firstOrderDetail.order?.sellerIs == 'admin'
                ? "${config?.inHouseShop?.imageFullUrl?.path}"
                : firstOrderDetail.seller?.imageFullUrl?.path,
            isShopOnVacation: isVacationActive,
            isShopTemporaryClosed: firstOrderDetail.seller?.shop?.temporaryClose ?? false,
          );
        } else {
          showCustomSnackBar(getTranslated('seller_not_available', context), context, isToaster: true);
        }
      } else {
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (_) => const NotLoggedInBottomSheetWidget());
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.storefront_outlined, color: AppPalette.primaryDeep, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getTranslated('products', context) ?? '',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
          Text('$count ${getTranslated(count > 1 ? 'items' : 'item', context)} · $shopName',
              maxLines: 1, overflow: TextOverflow.ellipsis,
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
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19, color: AppPalette.primaryDeep),
        ),
      ]),
    );
  }
}
