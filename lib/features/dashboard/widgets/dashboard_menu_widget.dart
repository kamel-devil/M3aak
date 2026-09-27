import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/color_resources.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class CustomMenuWidget extends StatefulWidget {
  final bool isSelected;
  final String name;
  final String icon;
  final bool showCartCount;
  final VoidCallback onTap;

  const CustomMenuWidget({
    super.key,
    required this.isSelected,
    required this.name,
    required this.icon,
    required this.onTap,
    this.showCartCount = false,
  });

  @override
  State<CustomMenuWidget> createState() => _CustomMenuWidgetState();
}

class _CustomMenuWidgetState extends State<CustomMenuWidget> {
  @override
  Widget build(BuildContext context) {
    const primary = ColorResources.accentPurple;
    const pillColor = ColorResources.navPillBackground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 14 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected ? pillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    widget.icon,
                    color: widget.isSelected
                        ? primary
                        : Theme.of(context).hintColor,
                    width: 20,
                    height: 20,
                  ),
                  if (widget.showCartCount)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Consumer<CartController>(
                        builder: (_, cart, __) {
                          if (cart.cartList.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            key: ValueKey(cart.cartList.length),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorResources.cartBadge,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cart.cartList.length}',
                              style: textBold.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: widget.isSelected
                    ? textBold.copyWith(
                        color: primary,
                        fontSize: 11,
                      )
                    : textRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 11,
                      ),
                child: Text(
                  getTranslated(widget.name, context) ?? widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
