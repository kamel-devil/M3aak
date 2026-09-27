import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:kk_thotix_m3aak/features/search_product/controllers/search_product_controller.dart';

import '../../../helper/route_healper.dart';
import 'barcode_scan_screen.dart';

class SearchHomePageWidget extends StatelessWidget {
  const SearchHomePageWidget({super.key});

  Future<void> _scanBarcode(BuildContext context) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );

    if (code == null || code.isEmpty) return;

    // Search for product by barcode
    if (context.mounted) {
      RouterHelper.getSearchRoute(action: RouteAction.push);
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Provider.of<SearchProductController>(context, listen: false)
            .searchProductByBarcode(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraExtraSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.homePagePadding,
          vertical: Dimensions.paddingSizeSmall,
        ),
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.only(
            left: isLtr ? Dimensions.homePagePadding : Dimensions.paddingSizeExtraSmall,
            right: isLtr ? Dimensions.paddingSizeExtraSmall : Dimensions.homePagePadding,
          ),
          height: 60,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: isDark
                ? null
                : [
              BoxShadow(
                color: Theme.of(context).hintColor.withValues(alpha: .1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 0),
              )
            ],
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getTranslated('search_hint', context) ?? '',
                style: textRegular.copyWith(color: Theme.of(context).hintColor),
              ),

              Row(
                children: [
                  // Barcode / QR button
                  InkWell(
                    onTap: () => _scanBarcode(context),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: .12),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: Theme.of(context).primaryColor,
                        size: Dimensions.iconSizeSmall,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Existing search icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(Dimensions.paddingSizeExtraSmall),
                      ),
                    ),
                    child: Icon(
                      Icons.search,
                      color: isDark ? Colors.white : Theme.of(context).cardColor,
                      size: Dimensions.iconSizeSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}