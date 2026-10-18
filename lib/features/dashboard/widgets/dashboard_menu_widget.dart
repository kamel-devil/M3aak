import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class CustomMenuWidget extends StatelessWidget {
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

  static const Map<String, List<IconData>> _icons = {
    'home': [Icons.home_outlined, Icons.home_rounded],
    'CATEGORY': [Icons.medication_outlined, Icons.medication_rounded],
    'cart': [Icons.shopping_bag_outlined, Icons.shopping_bag_rounded],
    'orders': [Icons.receipt_long_outlined, Icons.receipt_long_rounded],
    'more': [Icons.person_outline_rounded, Icons.person_rounded],
  };

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    final Color idle = Theme.of(context).hintColor;
    final List<IconData>? iconPair = _icons[name];

    final Widget iconWidget = iconPair != null
        ? Icon(isSelected ? iconPair[1] : iconPair[0],
            size: 22, color: isSelected ? Colors.white : idle)
        : Image.asset(icon,
            width: 20, height: 20, color: isSelected ? Colors.white : idle);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            // No overshooting curve here: the shadow below interpolates and
            // an overshoot would drive its blur radius negative (assertion).
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            width: isSelected ? 46 : 36,
            height: isSelected ? 34 : 30,
            decoration: BoxDecoration(
              gradient: isSelected ? AppPalette.brandGradient : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: isSelected ? .35 : 0),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  child: iconWidget,
                ),
                if (showCartCount)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Consumer<CartController>(
                      builder: (_, cart, __) {
                        if (cart.cartList.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return TweenAnimationBuilder<double>(
                          key: ValueKey(cart.cartList.length),
                          tween: Tween(begin: .4, end: 1),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.elasticOut,
                          builder: (_, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: AppPalette.offerGradient,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              '${cart.cartList.length}',
                              textAlign: TextAlign.center,
                              style: textBold.copyWith(
                                  color: Colors.white, fontSize: 9),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: (isSelected ? textBold : textRegular).copyWith(
              color: isSelected ? primary : idle,
              fontSize: 10.5,
            ),
            child: Text(
              getTranslated(name, context) ?? name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
