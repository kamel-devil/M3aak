import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/more/widgets/faq_expansion_tile_widget.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class FaqScreen extends StatefulWidget {
  final String? title;
  const FaqScreen({super.key, required this.title});

  @override
  FaqScreenState createState() => FaqScreenState();
}

class FaqScreenState extends State<FaqScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final faqs = splashController.configModel?.faq ?? [];
    final List<int> visible = [
      for (int i = 0; i < faqs.length; i++)
        if (_query.isEmpty
            || (faqs[i].question ?? '').toLowerCase().contains(_query.toLowerCase())
            || (faqs[i].answer ?? '').toLowerCase().contains(_query.toLowerCase())) i,
    ];

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: faqs.isEmpty
          ? const NoInternetOrDataScreenWidget(isNoInternet: false)
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: AppPalette.glassBorder(context)),
                  ),
                  child: Row(children: [
                    Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 21),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(
                      onChanged: (v) => setState(() => _query = v.trim()),
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintText: getTranslated('search_questions', context),
                        hintStyle: textRegular.copyWith(color: Theme.of(context).hintColor),
                      ),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),
                for (final i in visible) ...[
                  FadeSlideIn(index: i < 6 ? i : 6, child: FaqExpansionTileWidget(index: i, faq: splashController)),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(22)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(getTranslated('did_not_find_answer', context) ?? '',
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
                      Text(getTranslated('our_team_is_ready_to_help', context) ?? '',
                          style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall)),
                    ])),
                    TextButton(
                      onPressed: () => RouterHelper.getContactUsScreenRoute(action: RouteAction.push),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Text(getTranslated('contact_us', context) ?? '',
                          style: textBold.copyWith(color: AppPalette.primaryDeep, fontSize: Dimensions.fontSizeSmall + 1)),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }
}
