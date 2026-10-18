import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:kk_thotix_m3aak/features/chat/controllers/chat_controller.dart';


class ConversationListTabview extends StatelessWidget {
  final TabController? tabController;
  const ConversationListTabview({super.key, this.tabController});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
        builder: (context, chatProvider,_) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        child: GlassContainer(
          blur: false,
          radius: 20,
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: tabController,
            isScrollable: false,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: AppPalette.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .30), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).hintColor,
            labelStyle: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
            unselectedLabelStyle: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
            splashBorderRadius: BorderRadius.circular(16),
            tabs: [
              Tab(height: 44, text: getTranslated('delivery-man', context)),
              Tab(height: 44, text: getTranslated('vendor', context)),
            ],
            onTap: (index) {
              if (chatProvider.isActiveSuffixIcon) {
                chatProvider.setUserTypeIndex(context, tabController!.index, searchActive: true);
              } else {
                chatProvider.setUserTypeIndex(context, tabController!.index);
              }
            },
          ),
        ),
      );
    });
  }
}
