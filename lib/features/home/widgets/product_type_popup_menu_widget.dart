import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/enums/product_type.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ProductPopupFilterWidget extends StatelessWidget {
  const ProductPopupFilterWidget({super.key});

  static const List<(ProductType, String, IconData)> _options = [
    (ProductType.newArrival, 'new_arrival', Icons.auto_awesome_rounded),
    (ProductType.topProduct, 'top_product', Icons.star_rounded),
    (ProductType.bestSelling, 'best_selling', Icons.local_fire_department_rounded),
    (ProductType.discountedProduct, 'discounted_product', Icons.local_offer_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductType>(
        selector: (_, productController) => productController.productType,
        builder: (ctx, productType, _) {
          final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Container(width: 4, height: 20, margin: const EdgeInsetsDirectional.only(end: 8),
                  decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(4))),
              Expanded(child: Text(_getFilterTypeTitle(productType, context), style: titleHeader.copyWith(color: textColor))),

              PopupMenuButton<ProductType>(
                tooltip: getTranslated('sort_by', context),
                padding: EdgeInsets.zero,
                offset: const Offset(0, 48),
                elevation: 12,
                shadowColor: Colors.black.withValues(alpha: .25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppPalette.glassBorder(context)),
                ),
                color: Theme.of(context).cardColor,
                menuPadding: const EdgeInsets.symmetric(vertical: 6),
                itemBuilder: (context) => [
                  for (final (type, key, icon) in _options)
                    PopupMenuItem<ProductType>(
                      value: type,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _SortOption(
                        icon: icon,
                        label: getTranslated(key, context) ?? key,
                        selected: productType == type,
                      ),
                    ),
                ],
                onSelected: (ProductType value) {
                  Provider.of<ProductController>(context, listen: false).onChangeSelectedProductType(value);
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppPalette.glass(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: 1.2),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.swap_vert_rounded, size: 18, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(getTranslated('sort_by', context) ?? '',
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).primaryColor)),
                  ]),
                ),
              ),
            ]),
          );
        });
  }

  String _getFilterTypeTitle(ProductType type, BuildContext context) {
    for (final (t, key, _) in _options) {
      if (t == type) return getTranslated(key, context)!;
    }
    return getTranslated('new_arrival', context)!;
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({required this.icon, required this.label, required this.selected});
  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? primary.withValues(alpha: .10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: selected ? AppPalette.brandGradient : null,
            color: selected ? null : AppPalette.tint(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: selected ? Colors.white : primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: (selected ? textBold : textMedium).copyWith(
          color: selected ? primary : Theme.of(context).textTheme.bodyLarge?.color,
        ))),
        if (selected) Icon(Icons.check_circle_rounded, size: 18, color: primary),
      ]),
    );
  }
}
