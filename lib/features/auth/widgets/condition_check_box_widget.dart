import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/business_pages_model.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';


class ConditionCheckBox extends StatelessWidget {
  const ConditionCheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Provider.of<SplashController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
      child: Consumer<AuthController>(
        builder: (ctx, authController, _){
          return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            InkWell(
              onTap: ()=> authController.toggleTermsCheck(),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  margin: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: authController.isAcceptTerms ? AppPalette.brandGradient : null,
                    color: authController.isAcceptTerms ? null : Colors.white,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(7)),
                  child: Icon(CupertinoIcons.checkmark_alt, size: 15,
                      color: authController.isAcceptTerms ? Colors.white : Colors.transparent)),
                const SizedBox(width: 8),
              ]),
            ),
            Text(getTranslated('i_agree_with_the', context)!, style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
            InkWell(
              onTap: ()=> RouterHelper.getHtmlViewRoute(
                page: getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages)!,
              ),

              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Text(getTranslated('terms_condition', context)!, style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor,
                )),
              ),
            ),
          ]);
        }
      ),
    );
  }

  BusinessPageModel? getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if(pagesList != null && pagesList.isNotEmpty){
      for (var page in pagesList) {
        if(page.slug == slug) {
          pageModel = page;
        }
      }
    }

    return pageModel;
  }

}
