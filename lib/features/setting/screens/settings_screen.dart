import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/setting/widgets/select_language_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/setting/widgets/select_currency_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashController>(context, listen: false).setFromSetting(true);

    final String languageCode = Provider.of<LocalizationController>(context).locale.languageCode;
    final String languageName = AppConstants.languages
            .where((l) => l.languageCode == languageCode)
            .map((l) => l.languageName)
            .firstOrNull ??
        languageCode;
    final splash = Provider.of<SplashController>(context);
    final String currency = '${splash.myCurrency?.name ?? ''} (${PriceConverter.currencySymbol(context)})';
    final String? version = splash.configModel?.softwareVersion;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        Provider.of<SplashController>(context, listen: false).setFromSetting(false);
        return;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: getTranslated('settings', context)),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          children: [
            _GroupLabel(getTranslated('preferences', context) ?? ''),
            FadeSlideIn(
              child: _SettingsGroup(children: [
                _SettingsRow(
                  icon: Icons.language_rounded,
                  color: AppPalette.secondary,
                  title: getTranslated('choose_language', context) ?? '',
                  value: languageName,
                  onTap: () => showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => const SelectLanguageBottomSheetWidget(),
                  ),
                ),
                _SettingsRow(
                  icon: Icons.payments_outlined,
                  color: AppPalette.warning,
                  title: getTranslated('currency', context) ?? '',
                  value: currency,
                  onTap: () => showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => const SelectCurrencyBottomSheetWidget(),
                  ),
                ),
                Consumer<ThemeController>(builder: (context, theme, _) {
                  return _SettingsRow(
                    icon: theme.darkTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: const Color(0xFF5B6BD6),
                    title: getTranslated('dark_theme', context) ?? '',
                    onTap: theme.toggleTheme,
                    trailing: Switch.adaptive(
                      value: theme.darkTheme,
                      activeTrackColor: AppPalette.primary,
                      onChanged: (_) => theme.toggleTheme(),
                    ),
                  );
                }),
              ]),
            ),
            if (version != null && version.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _GroupLabel(getTranslated('about_app', context) ?? ''),
              FadeSlideIn(
                index: 1,
                child: _SettingsGroup(children: [
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    color: AppPalette.primary,
                    title: getTranslated('app_version', context) ?? '',
                    value: version,
                    trailing: const SizedBox.shrink(),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
      child: Text(text,
          style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).hintColor)),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    for (final child in children) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 1, indent: 66, endIndent: 14, color: Theme.of(context).dividerColor));
      }
      rows.add(child);
    }
    return GlassContainer(
      blur: false,
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: rows),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: color.withValues(alpha: .14),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
            if (value != null)
              Flexible(
                child: Text(value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).primaryColor)),
              ),
            const SizedBox(width: 4),
            trailing ??
                Icon(rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                    size: 20, color: Theme.of(context).hintColor),
          ]),
        ),
      ),
    );
  }
}
