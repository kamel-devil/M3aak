import 'package:flutter/material.dart';
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
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
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
    // var authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
            floating: true,
            elevation: 0,
            expandedHeight: 160,
            pinned: true,
            centerTitle: false,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).highlightColor,
            collapsedHeight: 160,
            flexibleSpace: const ProfileInfoSectionWidget()),
        SliverToBoxAdapter(
            child: Container(
          decoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          child: Consumer<AuthController>(builder: (ctx, authController, _) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall),
                      child: Center(child: MoreHorizontalSection())),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        0),
                    child: Text(
                      getTranslated('general', context) ?? '',
                      style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  Consumer<SplashController>(
                      builder: (context, splashController, _) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Container(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.fontSizeExtraSmall),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .hintColor
                                      .withValues(alpha: .05),
                                  blurRadius: 1,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 1))
                            ],
                            color:
                                Provider.of<ThemeController>(context).darkTheme
                                    ? Colors.white.withValues(alpha: .05)
                                    : Theme.of(context).cardColor),
                        child: Column(children: [
                          MenuButtonWidget(
                            image: Images.trackOrderIcon,
                            title: getTranslated('TRACK_ORDER', context),
                            onTap: () {
                              RouterHelper.getGuestTrackOrderRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          if (authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.user,
                              title: getTranslated('profile', context),
                              onTap: () {
                                RouterHelper.getProfileScreen1Route(
                                    action: RouteAction.push);
                              },
                            ),
                          MenuButtonWidget(
                            image: Images.address,
                            title: getTranslated('addresses', context),
                            onTap: () {
                              RouterHelper.getAddressListScreen(
                                  action: RouteAction.push);
                            },
                          ),
                          MenuButtonWidget(
                            image: Images.coupon,
                            title: getTranslated('coupons', context),
                            onTap: () {
                              RouterHelper.getCouponListScreenRoute();
                            },
                          ),
                          if (authController.isLoggedIn())
                            if (splashController
                                    .configModel?.refEarningStatus ==
                                "1")
                              MenuButtonWidget(
                                image: Images.refIcon,
                                title: getTranslated('refer_and_earn', context),
                                isProfile: true,
                                onTap: () {
                                  RouterHelper.getReferAndEarnRoute(
                                      action: RouteAction.push);
                                },
                              ),
                          MenuButtonWidget(
                            image: Images.category,
                            title: getTranslated('CATEGORY', context),
                            onTap: () {
                              RouterHelper.getCategoryScreenRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          if (authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.restockIcon,
                              title: getTranslated('restock_requests', context),
                              onTap: () {
                                RouterHelper.getRestockListRoute(
                                    action: RouteAction.push);
                              },
                            ),
                          if (splashController.configModel!.activeTheme !=
                                  "default" &&
                              authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.compare,
                              title: getTranslated('compare_products', context),
                              onTap: () {
                                RouterHelper.getCompareProductScreenRoute();
                              },
                            ),
                          MenuButtonWidget(
                            image: Images.notification,
                            title: getTranslated(
                              'notification',
                              context,
                            ),
                            isNotification: true,
                            onTap: () {
                              RouterHelper.getNotificationRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          MenuButtonWidget(
                            image: Images.settings,
                            title: getTranslated('settings', context),
                            onTap: () {
                              RouterHelper.getSettingsRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          if (splashController
                                  .configModel?.blogUrl?.isNotEmpty ??
                              false)
                            MenuButtonWidget(
                                image: Images.blogIcon,
                                title: getTranslated('blog', context),
                                onTap: () {
                                  RouterHelper.getBlogScreenRoute(
                                      action: RouteAction.push,
                                      url: splashController
                                              .configModel?.blogUrl ??
                                          '');
                                }),
                        ]),
                      ),
                    );
                  }),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          0),
                      child: Text(
                          getTranslated('help_and_support', context) ?? '',
                          style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).colorScheme.onPrimary))),
                  Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Container(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.fontSizeExtraSmall),
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: .05),
                                    blurRadius: 1,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 1))
                              ],
                              color: Provider.of<ThemeController>(context)
                                      .darkTheme
                                  ? Colors.white.withValues(alpha: .05)
                                  : Theme.of(context).cardColor),
                          child: Consumer<SplashController>(
                              builder: (context, splashController, _) {
                            return Column(children: [
                              singleVendor
                                  ? const SizedBox()
                                  : MenuButtonWidget(
                                      image: Images.chats,
                                      title: getTranslated('inbox', context),
                                      onTap: () {
                                        RouterHelper.getInboxScreenRoute(
                                            action: RouteAction.push);
                                      },
                                    ),
                              MenuButtonWidget(
                                image: Images.callIcon,
                                title: getTranslated('contact_us', context),
                                onTap: () {
                                  RouterHelper.getContactUsScreenRoute();
                                },
                              ),
                              MenuButtonWidget(
                                image: Images.preference,
                                title: getTranslated('support_ticket', context),
                                onTap: () {
                                  RouterHelper.getSupportTicketRoute(
                                      action: RouteAction.push);
                                },
                              ),
                              if (splashController.defaultBusinessPages !=
                                      null &&
                                  splashController
                                      .defaultBusinessPages!.isNotEmpty) ...[
                                if (getPageBySlug(
                                        'terms-and-conditions',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'terms_condition', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'terms-and-conditions',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'privacy-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.privacyPolicy,
                                      title: getTranslated(
                                          'privacy_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'privacy-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'refund-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'refund_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'refund-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'return-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'return_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'return-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'cancellation-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'cancellation_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'cancellation-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'shipping-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'shipping_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'shipping-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                              ],
                              MenuButtonWidget(
                                image: Images.faq,
                                title: getTranslated('faq', context),
                                onTap: () {
                                  RouterHelper.getFaqRoute(
                                      action: RouteAction.push);
                                },
                              ),
                              if (getPageBySlug('about-us',
                                      splashController.defaultBusinessPages) !=
                                  null)
                                MenuButtonWidget(
                                    image: Images.user,
                                    title: getTranslated('about_us', context),
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                        page: getPageBySlug(
                                            'about-us',
                                            splashController
                                                .defaultBusinessPages)!)),
                              if (splashController.businessPages != null &&
                                  splashController.businessPages!.isNotEmpty)
                                ListView.builder(
                                    itemCount:
                                        splashController.businessPages?.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MenuButtonWidget(
                                        image: Images.termCondition,
                                        title: splashController
                                            .businessPages?[index].title,
                                        onTap: () {
                                          RouterHelper.getHtmlViewRoute(
                                              page: splashController
                                                  .businessPages![index]);
                                        },
                                      );
                                    })
                            ]);
                          }))),
                  ListTile(
                    leading: SizedBox(
                        width: 30,
                        child: Image.asset(
                          Images.logOut,
                          color: Theme.of(context).primaryColor,
                        )),
                    title: Text(
                        !authController.isLoggedIn()
                            ? getTranslated('sign_in', context)!
                            : getTranslated('sign_out', context)!,
                        style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    onTap: () {
                      if (!authController.isLoggedIn()) {
                        RouterHelper.getLoginRoute(
                            action: RouteAction.push,
                            fromPage:
                                '${RouterHelper.dashboardScreen}?page=more');
                      } else {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (_) =>
                                const LogoutCustomBottomSheetWidget());
                      }
                    },
                  ),
                  Center(child: const PremiumFooter()),
                  SizedBox(
                    height: 90,
                  ),
                ]);
          }),
        )),
      ]),
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

class PremiumFooter extends StatefulWidget {
  const PremiumFooter({super.key});

  @override
  State<PremiumFooter> createState() => _PremiumFooterState();
}

class _PremiumFooterState extends State<PremiumFooter> {
  bool _isThotixHovered = false;
  bool _isSmartdukkanHovered = false;

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: Dimensions.paddingSizeDefault,
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(isDark ? .12 : .06),
              theme.primaryColor.withOpacity(isDark ? .05 : .01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.primaryColor.withOpacity(isDark ? .25 : .12),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(isDark ? .1 : .05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  getTranslated('Crafted with Excellence', context) ??
                      'Crafted with Excellence',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: theme.primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// DESIGNED BY SECTION
            Column(
              children: [
                Text(
                  getTranslated('Designed & Developed by', context) ??
                      'Designed & Developed by',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: theme.hintColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                MouseRegion(
                  onEnter: (_) => setState(() => _isThotixHovered = true),
                  onExit: (_) => setState(() => _isThotixHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _isThotixHovered
                          ? theme.primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _open('https://thotix.net'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.code_rounded,
                                size: 20,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Thotix.net',
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_outward_rounded,
                                size: 16,
                                color: theme.primaryColor.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// DIVIDER
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0),
                    theme.primaryColor.withOpacity(0.2),
                    theme.primaryColor.withOpacity(0),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            //
            // /// SMARTDUKKAN LINK
            // MouseRegion(
            //   onEnter: (_) => setState(() => _isSmartdukkanHovered = true),
            //   onExit: (_) => setState(() => _isSmartdukkanHovered = false),
            //   child: AnimatedContainer(
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.easeInOut,
            //     padding: EdgeInsets.symmetric(
            //       horizontal: 18,
            //       vertical: _isSmartdukkanHovered ? 14 : 12,
            //     ),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(16),
            //       gradient: _isSmartdukkanHovered
            //           ? LinearGradient(
            //               colors: [
            //                 theme.primaryColor.withOpacity(0.2),
            //                 theme.primaryColor.withOpacity(0.1),
            //               ],
            //             )
            //           : LinearGradient(
            //               colors: [
            //                 theme.primaryColor.withOpacity(0.1),
            //                 theme.primaryColor.withOpacity(0.05),
            //               ],
            //             ),
            //       border: Border.all(
            //         color: theme.primaryColor.withOpacity(
            //           _isSmartdukkanHovered ? 0.3 : 0.15,
            //         ),
            //       ),
            //       boxShadow: _isSmartdukkanHovered
            //           ? [
            //               BoxShadow(
            //                 color: theme.primaryColor.withOpacity(0.15),
            //                 blurRadius: 12,
            //                 offset: const Offset(0, 4),
            //               ),
            //             ]
            //           : null,
            //     ),
            //     child: Material(
            //       color: Colors.transparent,
            //       child: InkWell(
            //         onTap: () => _open('https://smartdukkan.com'),
            //         borderRadius: BorderRadius.circular(16),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Icon(
            //               Icons.language_rounded,
            //               size: 20,
            //               color: theme.primaryColor,
            //             ),
            //             const SizedBox(width: 10),
            //             Text(
            //               'smartdukkan.com',
            //               style: textMedium.copyWith(
            //                 fontSize: Dimensions.fontSizeDefault,
            //                 color: theme.primaryColor,
            //               ),
            //             ),
            //             const SizedBox(width: 6),
            //             Icon(
            //               Icons.arrow_outward_rounded,
            //               size: 14,
            //               color: theme.primaryColor.withOpacity(0.6),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            //
            // const SizedBox(height: 16),

            /// FOOTER TEXT
            Text(
              getTranslated('Thotix eCommerce Solution', context) ??
                  'Thotix eCommerce Solution',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall - 1,
                color: theme.hintColor.withOpacity(0.7),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
