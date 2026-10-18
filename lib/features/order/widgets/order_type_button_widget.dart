import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/order/controllers/order_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Segmented "running | delivered | canceled" switch with a sliding pill.
class OrderStatusTabs extends StatelessWidget {
  const OrderStatusTabs({super.key});

  static const List<String> _labels = ['RUNNING', 'DELIVERED', 'CANCELED'];

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(builder: (context, orderController, _) {
      final int selected = orderController.orderTypeIndex;

      return GlassContainer(
        blur: false,
        radius: 20,
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 42,
          child: LayoutBuilder(builder: (context, constraints) {
            final double segment = constraints.maxWidth / _labels.length;
            final bool rtl = Directionality.of(context) == TextDirection.rtl;
            final double offset = segment * selected;

            return Stack(children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: rtl ? null : offset,
                right: rtl ? offset : null,
                top: 0,
                bottom: 0,
                width: segment,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppPalette.brandGradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.primary.withValues(alpha: .30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(children: [
                for (int i = 0; i < _labels.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selected,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i != selected) orderController.setIndex(i);
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: i == selected ? Colors.white : Theme.of(context).hintColor,
                            ),
                            child: Text(getTranslated(_labels[i], context) ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ]);
          }),
        ),
      );
    });
  }
}
