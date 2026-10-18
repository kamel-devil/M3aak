import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/more/widgets/more_horizontal_section_widget.dart';
import 'package:kk_thotix_m3aak/features/more/widgets/profile_info_section_widget.dart';
import 'package:kk_thotix_m3aak/features/more/widgets/title_button_widget.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/business_pages_model.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String? version;
  bool singleVendor = false;

  @override
  void initState() {
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      version = Provider.of<SplashController>(context, listen: false)
              .configModel!
              .softwareVersion ??
          'version';
      Provider.of<ProfileController>(context, listen: false)
          .getUserInfo(context);
    }
    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel!
            .businessMode ==
        "single";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Consumer2<AuthController, SplashController>(
          builder: (context, authController, splashController, _) {
            final bool loggedIn = authController.isLoggedIn();
            final pages = splashController.defaultBusinessPages;

            Widget pageRow(String slug, String key) {
              final page = getPageBySlug(slug, pages);
              if (page == null) return const SizedBox.shrink();
              return MenuButtonWidget(
                image: Images.termCondition,
                color: AppPalette.lightInkSoft,
                title: getTranslated(key, context),
                onTap: () => RouterHelper.getHtmlViewRoute(page: page),
              );
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: 110),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: ProfileInfoSectionWidget(),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                const _SectionTitle(titleKey: 'quick_access'),
                const MoreHorizontalSection(),

                // General
                const _SectionTitle(titleKey: 'general'),
                _MenuGroup(index: 1, children: [
                  MenuButtonWidget(
                    image: Images.trackOrderIcon,
                    color: AppPalette.secondary,
                    title: getTranslated('TRACK_ORDER', context),
                    onTap: () => RouterHelper.getGuestTrackOrderRoute(action: RouteAction.push),
                  ),
                  if (loggedIn)
                    MenuButtonWidget(
                      image: Images.user,
                      title: getTranslated('profile', context),
                      onTap: () => RouterHelper.getProfileScreen1Route(action: RouteAction.push),
                    ),
                  MenuButtonWidget(
                    image: Images.address,
                    color: AppPalette.accent,
                    title: getTranslated('addresses', context),
                    onTap: () => RouterHelper.getAddressListScreen(action: RouteAction.push),
                  ),
                  MenuButtonWidget(
                    image: Images.coupon,
                    color: AppPalette.warning,
                    title: getTranslated('coupons', context),
                    onTap: () => RouterHelper.getCouponListScreenRoute(),
                  ),
                  if (loggedIn && splashController.configModel?.refEarningStatus == "1")
                    MenuButtonWidget(
                      image: Images.refIcon,
                      color: const Color(0xFF8B6CF0),
                      title: getTranslated('refer_and_earn', context),
                      isProfile: true,
                      onTap: () => RouterHelper.getReferAndEarnRoute(action: RouteAction.push),
                    ),
                  MenuButtonWidget(
                    image: Images.category,
                    title: getTranslated('CATEGORY', context),
                    onTap: () => RouterHelper.getCategoryScreenRoute(action: RouteAction.push),
                  ),
                  MenuButtonWidget(
                    image: Images.restockIcon,
                    icon: Icons.medical_information_rounded,
                    color: AppPalette.success,
                    title: getTranslated('prescriptions', context),
                    onTap: () => RouterHelper.getPrescriptionListRoute(action: RouteAction.push),
                  ),
                  if (loggedIn)
                    MenuButtonWidget(
                      image: Images.restockIcon,
                      color: AppPalette.secondary,
                      title: getTranslated('restock_requests', context),
                      onTap: () => RouterHelper.getRestockListRoute(action: RouteAction.push),
                    ),
                  if (splashController.configModel!.activeTheme != "default" && loggedIn)
                    MenuButtonWidget(
                      image: Images.compare,
                      color: AppPalette.primaryDeep,
                      title: getTranslated('compare_products', context),
                      onTap: () => RouterHelper.getCompareProductScreenRoute(),
                    ),
                  MenuButtonWidget(
                    image: Images.notification,
                    color: AppPalette.accent,
                    title: getTranslated('notification', context),
                    isNotification: true,
                    onTap: () => RouterHelper.getNotificationRoute(action: RouteAction.push),
                  ),
                  MenuButtonWidget(
                    image: Images.settings,
                    color: AppPalette.lightInkSoft,
                    title: getTranslated('settings', context),
                    onTap: () => RouterHelper.getSettingsRoute(action: RouteAction.push),
                  ),
                  Consumer<ThemeController>(builder: (context, theme, _) {
                    return MenuButtonWidget(
                      image: Images.settings,
                      icon: theme.darkTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: const Color(0xFF5B6BD6),
                      title: getTranslated('dark_theme', context),
                      onTap: theme.toggleTheme,
                      trailing: Switch.adaptive(
                        value: theme.darkTheme,
                        activeTrackColor: AppPalette.primary,
                        onChanged: (_) => theme.toggleTheme(),
                      ),
                    );
                  }),
                  if (splashController.configModel?.blogUrl?.isNotEmpty ?? false)
                    MenuButtonWidget(
                      image: Images.blogIcon,
                      color: AppPalette.warning,
                      title: getTranslated('blog', context),
                      onTap: () => RouterHelper.getBlogScreenRoute(
                          action: RouteAction.push, url: splashController.configModel?.blogUrl ?? ''),
                    ),
                ]),

                // Help & support
                const _SectionTitle(titleKey: 'help_and_support'),
                _MenuGroup(index: 2, children: [
                  if (!singleVendor)
                    MenuButtonWidget(
                      image: Images.chats,
                      color: AppPalette.secondary,
                      title: getTranslated('inbox', context),
                      onTap: () => RouterHelper.getInboxScreenRoute(action: RouteAction.push),
                    ),
                  MenuButtonWidget(
                    image: Images.callIcon,
                    color: AppPalette.success,
                    title: getTranslated('contact_us', context),
                    onTap: () => RouterHelper.getContactUsScreenRoute(),
                  ),
                  MenuButtonWidget(
                    image: Images.preference,
                    color: AppPalette.accent,
                    title: getTranslated('support_ticket', context),
                    onTap: () => RouterHelper.getSupportTicketRoute(action: RouteAction.push),
                  ),
                  MenuButtonWidget(
                    image: Images.faq,
                    color: AppPalette.warning,
                    title: getTranslated('faq', context),
                    onTap: () => RouterHelper.getFaqRoute(action: RouteAction.push),
                  ),
                  if (getPageBySlug('about-us', pages) != null)
                    MenuButtonWidget(
                      image: Images.user,
                      title: getTranslated('about_us', context),
                      onTap: () => RouterHelper.getHtmlViewRoute(page: getPageBySlug('about-us', pages)!),
                    ),
                ]),

                // Policies
                if ((pages?.isNotEmpty ?? false) || (splashController.businessPages?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _MenuGroup(index: 3, children: [
                    pageRow('terms-and-conditions', 'terms_condition'),
                    pageRow('privacy-policy', 'privacy_policy'),
                    pageRow('refund-policy', 'refund_policy'),
                    pageRow('return-policy', 'return_policy'),
                    pageRow('cancellation-policy', 'cancellation_policy'),
                    pageRow('shipping-policy', 'shipping_policy'),
                    for (final page in splashController.businessPages ?? [])
                      MenuButtonWidget(
                        image: Images.termCondition,
                        color: AppPalette.lightInkSoft,
                        title: page.title,
                        onTap: () => RouterHelper.getHtmlViewRoute(page: page),
                      ),
                  ]),
                ],

                // Sign in / out
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: _SignInOutTile(loggedIn: loggedIn),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),
                const Center(child: PremiumFooter()),
              ],
            );
          },
        ),
      ),
    );
  }

  BusinessPageModel? getPageBySlug(
      String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if (pagesList != null && pagesList.isNotEmpty) {
      for (var page in pagesList) {
        if (page.slug == slug) {
          pageModel = page;
        }
      }
    }
    return pageModel;
  }
}

/// Quiet footer: brand mark, app version and developer credit.
class PremiumFooter extends StatelessWidget {
  const PremiumFooter({super.key});

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? version = Provider.of<SplashController>(context, listen: false).configModel?.softwareVersion;
    final Color hint = Theme.of(context).hintColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCFF1EA), width: 1.5),
          ),
          child: Image.asset(Images.pharmacyIcon),
        ),
        const SizedBox(height: 8),
        Text(AppConstants.appName,
            style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        if (version != null && version.isNotEmpty) ...[
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Version $version',
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: hint)),
          ),
        ],
        const SizedBox(height: 2),
        InkWell(
          onTap: () => _open('https://thotix.net'),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '${getTranslated('designed_and_developed_by', context) ?? 'Designed & developed by'} ',
                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: hint)),
              TextSpan(text: 'Thotix.net',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
            ])),
          ),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.titleKey});
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault + 2, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 10),
      child: Row(children: [
        Container(
          width: 4,
          height: 16,
          margin: const EdgeInsetsDirectional.only(end: 8),
          decoration: BoxDecoration(
            gradient: AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(getTranslated(titleKey, context) ?? '',
            style: textBold.copyWith(
                fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ]),
    );
  }
}

/// Frosted card grouping menu rows with hairline separators.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children, this.index = 0});
  final List<Widget> children;
  final int index;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    for (final child in children) {
      if (child is SizedBox && child.width == 0 && child.height == 0) continue;
      if (rows.isNotEmpty) {
        rows.add(Divider(
          height: 1,
          indent: 62,
          endIndent: 14,
          color: Theme.of(context).dividerColor,
        ));
      }
      rows.add(child);
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return FadeSlideIn(
      index: index,
      child: GlassContainer(
        blur: false,
        radius: 24,
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: rows),
      ),
    );
  }
}

class _SignInOutTile extends StatelessWidget {
  const _SignInOutTile({required this.loggedIn});
  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    final Color color = loggedIn ? AppPalette.error : AppPalette.primary;
    return PressableScale(
      onTap: () {
        if (!loggedIn) {
          RouterHelper.getLoginRoute(
              action: RouteAction.push, fromPage: '${RouterHelper.dashboardScreen}?page=more');
        } else {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (_) => const LogoutCustomBottomSheetWidget());
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(loggedIn ? Icons.logout_rounded : Icons.login_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            loggedIn ? getTranslated('sign_out', context)! : getTranslated('sign_in', context)!,
            style: textBold.copyWith(color: color, fontSize: Dimensions.fontSizeLarge),
          ),
        ]),
      ),
    );
  }
}
