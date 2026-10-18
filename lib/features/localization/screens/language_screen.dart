import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  final bool fromSetting;
  const LanguageScreen({super.key, this.fromSetting = false});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = Provider.of<LocalizationController>(context, listen: false)
        .languageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 28),
          FadeSlideIn(child: Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppPalette.glassBorder(context)),
              boxShadow: AppPalette.softShadow(context),
            ),
            child: Image.asset(Images.pharmacyIcon),
          )),
          const SizedBox(height: 18),
          Text(getTranslated('select_language', context) ?? 'Select Language',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge + 2, color: textColor)),
          const SizedBox(height: 4),
          Text(getTranslated('choose_app_language', context) ?? '',
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppConstants.languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lang = AppConstants.languages[index];
                final bool selected = selectedIndex == index;
                return FadeSlideIn(
                  index: index,
                  child: Semantics(
                    selected: selected,
                    button: true,
                    child: PressableScale(
                      onTap: () => setState(() => selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        constraints: const BoxConstraints(minHeight: 66),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? primary.withValues(alpha: .07) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? primary : AppPalette.glassBorder(context), width: selected ? 1.5 : 1),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : AppPalette.tint(context),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Image.asset(lang.imageUrl!),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(lang.languageName!,
                              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor))),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? primary : Colors.transparent,
                              border: Border.all(color: selected ? primary : Theme.of(context).hintColor.withValues(alpha: .5), width: 2),
                            ),
                            child: selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: PressableScale(
              onTap: () {
                if (selectedIndex != null) {
                  Provider.of<LocalizationController>(context, listen: false).setLanguage(
                    Locale(AppConstants.languages[selectedIndex!].languageCode!, AppConstants.languages[selectedIndex!].countryCode),
                  );
                  if (widget.fromSetting) {
                    Navigator.pop(context);
                  } else {
                    RouterHelper.getOnboardingRoute(action: RouteAction.pushReplacement);
                  }
                }
              },
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Text(getTranslated('save', context) ?? 'Save',
                    style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
