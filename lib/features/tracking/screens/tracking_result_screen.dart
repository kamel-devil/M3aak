import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/order/controllers/order_controller.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingResultScreen extends StatefulWidget {
  final String orderID;
  const TrackingResultScreen({super.key, required this.orderID});

  @override
  State<TrackingResultScreen> createState() => _TrackingResultScreenState();
}

class _TrackingResultScreenState extends State<TrackingResultScreen> {
  static const List<String> _statusList = ['pending', 'confirmed', 'processing', 'out_for_delivery', 'delivered'];
  static const List<(String, IconData)> _steps = [
    ('order_placed', Icons.receipt_long_outlined),
    ('order_confirmed', Icons.check_rounded),
    ('preparing_for_shipment', Icons.inventory_2_outlined),
    ('order_is_on_the_way', Icons.local_shipping_outlined),
    ('order_delivered', Icons.home_rounded),
  ];

  @override
  void initState() {
    Provider.of<OrderController>(context, listen: false).initTrackingInfo(widget.orderID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('TRACK_ORDER', context)),
      body: Consumer<OrderController>(
        builder: (context, tracking, child) {
          final order = tracking.trackingModel;
          if (order == null) return const Center(child: CircularProgressIndicator());

          final int current = _statusList.indexOf(order.orderStatus ?? '');
          final bool stopped = current < 0;
          final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
          final String headline = stopped
              ? getTranslated(order.orderStatus, context) ?? ''
              : getTranslated(_steps[current].$1, context) ?? '';

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              FadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: stopped
                        ? const LinearGradient(colors: [Color(0xFFE5634F), Color(0xFFB4432F)])
                        : AppPalette.brandGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .25), blurRadius: 26, offset: const Offset(0, 12))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(17)),
                      child: Icon(stopped ? Icons.block_rounded : _steps[current].$2, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${getTranslated('your_order', context)} #${widget.orderID}',
                          style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall)),
                      Text(headline, style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge)),
                      if (order.updatedAt != null)
                        Text(DateConverter.localDateToIsoStringAMPMOrder(DateTime.parse(order.updatedAt!)),
                            style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall)),
                    ])),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              if (!stopped)
                FadeSlideIn(
                  index: 1,
                  child: GlassContainer(
                    blur: false,
                    radius: 24,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                    child: Column(children: [
                      for (int i = 0; i < _steps.length; i++)
                        _TimelineStep(
                          icon: _steps[i].$2,
                          title: getTranslated(_steps[i].$1, context) ?? '',
                          subtitle: i == 0 && order.createdAt != null
                              ? DateConverter.localDateToIsoStringAMPMOrder(DateTime.parse(order.createdAt!))
                              : null,
                          done: i < current,
                          active: i == current,
                          last: i == _steps.length - 1,
                        ),
                    ]),
                  ),
                ),

              if (order.deliveryMan != null) ...[
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 2,
                  child: GlassContainer(
                    blur: false,
                    radius: 22,
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(width: 48, height: 48,
                            child: CustomImageWidget(image: '${order.deliveryMan?.imageFullUrl?.path}', fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${order.deliveryMan?.fName ?? ''} ${order.deliveryMan?.lName ?? ''}'.trim(),
                            style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor)),
                        Text(getTranslated('delivery_man', context) ?? '',
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                      ])),
                      if ((order.deliveryMan?.phone ?? '').isNotEmpty)
                        IconButton(
                          tooltip: getTranslated('call', context),
                          onPressed: () => launchUrl(Uri.parse('tel:${order.deliveryMan!.phone}')),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            backgroundColor: AppPalette.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.call_rounded, color: Colors.white, size: 19),
                        ),
                    ]),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool done;
  final bool active;
  final bool last;
  const _TimelineStep({required this.icon, required this.title, this.subtitle, required this.done, required this.active, required this.last});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    final Color line = AppPalette.glassBorder(context);
    final bool reached = done || active;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Column(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? primary : active ? Theme.of(context).cardColor : AppPalette.tint(context),
              border: active ? Border.all(color: primary, width: 3) : (done ? null : Border.all(color: line, width: 1.5)),
              boxShadow: active ? [BoxShadow(color: primary.withValues(alpha: .2), spreadRadius: 5)] : null,
            ),
            child: Icon(done ? Icons.check_rounded : icon, size: 15,
                color: done ? Colors.white : active ? primary : Theme.of(context).hintColor),
          ),
          if (!last)
            Expanded(
              child: Container(
                width: 3,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: done ? primary : line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: last ? 12 : 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: (reached ? textBold : textMedium).copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: active ? AppPalette.primaryDeep : reached ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
              )),
              if (subtitle != null)
                Text(subtitle!, style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      ]),
    );
  }
}
