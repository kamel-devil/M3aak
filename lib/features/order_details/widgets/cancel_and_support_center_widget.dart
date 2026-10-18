import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/order/domain/models/order_model.dart';
import 'package:kk_thotix_m3aak/features/order_details/widgets/cancel_order_dialog_widget.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/reorder/controllers/re_order_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CancelAndSupportWidget extends StatelessWidget {
  final Orders? orderModel;
  final bool fromNotification;
  final bool showSupport;
  const CancelAndSupportWidget({super.key, this.orderModel, this.fromNotification = false, this.showSupport = false});

  @override
  Widget build(BuildContext context) {
    if (showSupport) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
        child: Center(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '${getTranslated('facing_a_problem', context)} ',
                  style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: InkWell(
                  onTap: () => RouterHelper.getSupportTicketRoute(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(getTranslated('contact_support_center', context) ?? '',
                        style: textBold.copyWith(
                          color: AppPalette.primaryDeep,
                          fontSize: Dimensions.fontSizeSmall,
                          decoration: TextDecoration.underline,
                          decorationColor: AppPalette.primaryDeep,
                        )),
                  ),
                ),
              ),
            ]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (orderModel == null) return const SizedBox();
    final bool loggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
    final bool isOwner = loggedIn && orderModel!.customerId == int.tryParse(Provider.of<ProfileController>(context, listen: false).userID);
    final bool notPos = orderModel!.orderType != "POS";
    final String? status = orderModel!.orderStatus;

    final bool canCancel = isOwner && status == 'pending' && notPos;
    final bool canReorder = isOwner && status == 'delivered' && notPos;
    final bool canTrack = isOwner && notPos && !canReorder &&
        status != 'canceled' && status != 'returned' && status != 'fail_to_delivered';

    if (!canCancel && !canReorder && !canTrack) return const SizedBox();

    Widget primary(String label, IconData icon, VoidCallback onTap) => Expanded(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .32), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 6),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault + 1))),
          ]),
        ),
      ),
    );

    return SafeArea(
      top: false,
      child: Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: .96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
        boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .10), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: Row(children: [
        if (canCancel)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => showDialog(context: context, builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: CancelOrderDialogWidget(orderId: orderModel!.id),
              )),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: AppPalette.error,
                side: BorderSide(color: AppPalette.error.withValues(alpha: .45), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.cancel_outlined, size: 19),
              label: Text(getTranslated('cancel_order', context) ?? '',
                  style: textBold.copyWith(color: AppPalette.error, fontSize: Dimensions.fontSizeDefault + 1)),
            ),
          ),
        if (canCancel && (canTrack || canReorder)) const SizedBox(width: 10),
        if (canReorder)
          primary(getTranslated('re_order', context) ?? '', Icons.replay_rounded,
              () => Provider.of<ReOrderController>(context, listen: false).reorder(orderId: orderModel?.id.toString())),
        if (canTrack)
          primary(getTranslated('TRACK_ORDER', context) ?? '', Icons.location_on_outlined,
              () => RouterHelper.getTrackingResultRoute(action: RouteAction.push, orderID: orderModel!.id.toString())),
      ]),
    ));
  }
}
