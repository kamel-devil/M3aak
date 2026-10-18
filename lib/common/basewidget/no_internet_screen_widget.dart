import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_asset_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';

class NoInternetOrDataScreenWidget extends StatelessWidget {
  final bool isNoInternet;
  final Widget? child;
  final String? message;
  final String? icon;
  final bool icCart;
  final EdgeInsets? padding;
  final double? iconSize;
  const NoInternetOrDataScreenWidget({super.key, required this.isNoInternet, this.child, this.message, this.icon,  this.icCart = false, this.padding, this.iconSize = 75});

  @override
  Widget build(BuildContext context) {
    final String text = isNoInternet
        ? getTranslated('no_internet_connection', context)!
        : message != null ? getTranslated(message, context) ?? '' : getTranslated('no_data_found', context) ?? '';

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: FadeSlideIn(
            child: GlassContainer(
              blur: false,
              radius: 28,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Soft halo around the illustration.
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppPalette.tint(context),
                      AppPalette.tint(context).withValues(alpha: .25),
                    ]),
                  ),
                  child: Container(
                    width: 78,
                    height: 78,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: AppPalette.softShadow(context),
                    ),
                    child: CustomAssetImageWidget(
                      isNoInternet ? Images.noInternet : icon ?? Images.noData,
                      height: iconSize, width: iconSize, fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                if (isNoInternet)
                  Text(getTranslated('OPPS', context)!,
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeOverLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),

                Text(text, textAlign: TextAlign.center, style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge + 1,
                  height: 1.4,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),

                if (isNoInternet) ...[
                  const SizedBox(height: 20),
                  CustomButton(
                    buttonText: getTranslated('RETRY', context),
                    onTap: () async {
                      List<ConnectivityResult> results = await Connectivity().checkConnectivity();
                      bool isConnected = results.any((result) => result != ConnectivityResult.none);
                      if (isConnected) {
                        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
                      }
                    },
                  ),
                ],

                if (icCart) ...[
                  const SizedBox(height: 20),
                  SizedBox(width: 200,
                    child: CustomButton(
                      onTap: () => RouterHelper.getDashboardRoute(action: RouteAction.push),
                      buttonText: '${getTranslated('continue_shopping', context)}'),
                  ),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
