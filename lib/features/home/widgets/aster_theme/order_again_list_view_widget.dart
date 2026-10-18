import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/order/controllers/order_controller.dart';
import 'package:kk_thotix_m3aak/features/order/domain/models/order_model.dart';
import 'package:kk_thotix_m3aak/features/reorder/controllers/re_order_controller.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/image_diaglog_widget.dart';
import 'package:provider/provider.dart';

class OrderAgainView extends StatelessWidget {
  const OrderAgainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, orderProvider, _) {
        final orders = orderProvider.deliveredOrderModel?.orders ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppPalette.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .22), blurRadius: 22, offset: const Offset(0, 10))],
            ),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: .4)),
                ),
                child: const Icon(Icons.replay_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(getTranslated('order_again', context)!,
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
                const SizedBox(height: 2),
                Text(getTranslated('want_to_order_your_usuals_just_reorder_from_your_previous_orders', context)!,
                    style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.4, color: Colors.white.withValues(alpha: .9))),
              ])),
            ]),
          ),

          for (int index = 0; index < orders.length && index < 2; index++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FadeSlideIn(index: index, child: OrderAgainCard(orders: orders[index])),
            ),
        ]);
      },
    );
  }
}


class OrderAgainCard extends StatelessWidget {
  final Orders orders;
  const OrderAgainCard({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final details = orders.details ?? [];

    return GlassContainer(
      blur: false,
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppPalette.success.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded, size: 14, color: AppPalette.success),
              const SizedBox(width: 4),
              Text(getTranslated('delivered', context)!,
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.success)),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(
            DateConverter.dateTimeStringToDateTime(orders.createdAt!),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
          )),
          Text('#${orders.id}', style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
        ]),
        const SizedBox(height: 12),

        if (details.isNotEmpty)
          Row(children: [
            for (int i = 0; i < details.length && i < 3; i++)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => showDialog(context: context, builder: (_) =>
                      ImageDialog(imageUrl: details[i].product?.thumbnailFullUrl?.path ?? '')),
                  child: Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppPalette.tint(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageWidget(fit: BoxFit.cover, image: details[i].product?.thumbnailFullUrl?.path ?? ''),
                    ),
                  ),
                ),
              ),
            if (details.length > 3)
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('+${details.length - 3}',
                    style: textBold.copyWith(color: Theme.of(context).primaryColor)),
              ),
          ]),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getTranslated('final_total', context)!,
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            Text(PriceConverter.convertPrice(context, orders.orderAmount),
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
          ])),

          Consumer<ReOrderController>(builder: (context, reOrderController, _) {
            final bool loading = reOrderController.isLoading;
            return PressableScale(
              onTap: loading ? null : () => reOrderController.reorder(orderId: orders.id.toString()),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: loading ? null : AppPalette.brandGradient,
                  color: loading ? Theme.of(context).disabledColor : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (loading)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  else
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(getTranslated('order_again', context)!,
                      style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall + 1)),
                ]),
              ),
            );
          }),
        ]),
      ]),
    );
  }
}
