import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/support/controllers/support_ticket_controller.dart';
import 'package:kk_thotix_m3aak/features/support/widgets/support_ticket_widget.dart';
import 'package:kk_thotix_m3aak/features/support/widgets/support_ticket_shimmer.dart';
import 'package:kk_thotix_m3aak/features/support/widgets/support_ticket_type_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_loggedin_widget.dart';
import 'package:provider/provider.dart';


class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});
  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  @override
  void initState() {
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<SupportTicketController>(context, listen: false).getSupportTicketList();
      if(Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
        Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('support_ticket', context)),
      bottomNavigationBar: Provider.of<AuthController>(context, listen: false).isLoggedIn() ?
      SafeArea(top: false, child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: .96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
            ),
            child: PressableScale(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const SupportTicketTypeWidget(),
              ),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(getTranslated('add_new_ticket', context) ?? '', style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                ]),
              ),
            ),
          )) : const SizedBox(),
      body: Consumer<SupportTicketController>(
        builder: (context, support, child) {
          return Provider.of<AuthController>(context, listen: false).isLoggedIn()?
          support.supportTicketList != null ?
          support.supportTicketList!.isNotEmpty?
          RefreshIndicator(
            onRefresh: () async => await support.getSupportTicketList(),
            child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: support.supportTicketList!.length,
                itemBuilder: (context, index) => SupportTicketWidget(supportTicketModel: support.supportTicketList![index], index: index),
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            ),
          ) : const NoInternetOrDataScreenWidget(isNoInternet: false, icon: Images.noTicket,
            message: 'no_ticket_created') : const SupportTicketShimmer() : NotLoggedInWidget(fromPage: RouterHelper.supportTicketScreen,
            onLoginSuccess: () {
              RouterHelper.getSupportTicketRoute(action: RouteAction.pushReplacement);
            }
          );
        },
      ),
    );
  }
}



