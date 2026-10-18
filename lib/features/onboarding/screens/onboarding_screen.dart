import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/onboarding/controllers/onboarding_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';
import '../../../../helper/route_healper.dart';

class OnBoardingScreen extends StatelessWidget {
  final Color indicatorColor;
  final Color selectedIndicatorColor;
  OnBoardingScreen({super.key, this.indicatorColor = Colors.grey, this.selectedIndicatorColor = Colors.black});
  final PageController _pageController = PageController();

  void _finish(BuildContext context) {
    Provider.of<SplashController>(context, listen: false).disableIntro();
    Provider.of<AuthController>(context, listen: false).getGuestIdUrl();
    RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingController>(context, listen: false).getOnBoardingList();

    return Scaffold(
      body: SafeArea(
        child: Consumer<OnBoardingController>(builder: (context, onBoardingList, child) {
          final int count = onBoardingList.onBoardingList.length;
          final bool last = onBoardingList.selectedIndex == count - 1;
          final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: last ? 0 : 1,
                  child: TextButton(
                    onPressed: last ? null : () => _finish(context),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor: Theme.of(context).cardColor.withValues(alpha: .8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('${getTranslated('skip', context)}',
                        style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  itemCount: count,
                  controller: _pageController,
                  onPageChanged: (index) => onBoardingList.changeSelectIndex(index),
                  itemBuilder: (context, index) {
                    final item = onBoardingList.onBoardingList[index];
                    return Column(children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                AppPalette.primary.withValues(alpha: .20),
                                AppPalette.primary.withValues(alpha: .04),
                              ]),
                            ),
                            padding: const EdgeInsets.all(34),
                            child: Image.asset(item.imageUrl, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      Text(item.title ?? '', textAlign: TextAlign.center,
                          style: textBold.copyWith(fontSize: 24, height: 1.4, color: textColor)),
                      const SizedBox(height: 10),
                      Text(item.description ?? '', textAlign: TextAlign.center,
                          style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge, height: 1.8, color: Theme.of(context).hintColor)),
                      const SizedBox(height: 24),
                    ]);
                  },
                ),
              ),

              Row(children: [
                Expanded(
                  child: Row(children: [
                    for (int i = 0; i < count; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        width: i == onBoardingList.selectedIndex ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: i == onBoardingList.selectedIndex ? AppPalette.brandGradient : null,
                          color: i == onBoardingList.selectedIndex ? null : AppPalette.primary.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ]),
                ),
                PressableScale(
                  onTap: () {
                    if (last) {
                      _finish(context);
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
                    }
                  },
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(getTranslated(last ? 'explore' : 'next', context) ?? '',
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(width: 8),
                      Icon(last ? Icons.check_rounded : Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ]),
                  ),
                ),
              ]),
            ]),
          );
        }),
      ),
    );
  }
}
