import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Center(child: Image.asset(Images.logoWithNameImage, height: 100)),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Text(
              getTranslated('select_language', context) ?? 'Select Language',
              style:
                  textMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                itemCount: AppConstants.languages.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall),
                      margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(Dimensions.paddingSizeSmall),
                        border: Border.all(
                          color: selectedIndex == index
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppConstants.languages[index].imageUrl!,
                              height: 30, width: 30),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Text(AppConstants.languages[index].languageName!,
                              style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                          const Spacer(),
                          if (selectedIndex == index)
                            Icon(Icons.check_circle,
                                color: Theme.of(context).primaryColor)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButton(
                buttonText: getTranslated('save', context) ?? 'Save',
                onTap: () {
                  if (selectedIndex != null) {
                    Provider.of<LocalizationController>(context, listen: false)
                        .setLanguage(
                      Locale(
                          AppConstants.languages[selectedIndex!].languageCode!,
                          AppConstants.languages[selectedIndex!].countryCode),
                    );
                    if (widget.fromSetting) {
                      Navigator.pop(context);
                    } else {
                      RouterHelper.getOnboardingRoute(
                          action: RouteAction.pushReplacement);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
