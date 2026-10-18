import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/wishlist/controllers/wishlist_controller.dart';
import 'package:kk_thotix_m3aak/features/wishlist/widgets/wishlist_shimmer.dart';
import 'package:kk_thotix_m3aak/features/wishlist/widgets/wishlist_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_loggedin_widget.dart';
import 'package:provider/provider.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});
  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  void initState() {
    super.initState();
    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<WishListController>(context, listen: false).getWishList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        if(Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
          Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page : 'more');
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: getTranslated('wishList', context)),
        resizeToAvoidBottomInset: true,
        body: Column(children: [

          Expanded(child: !Provider.of<AuthController>(context, listen: false).isLoggedIn() ?
          NotLoggedInWidget(
            fromPage: RouterHelper.wishListScreen,
            onLoginSuccess: () {
              RouterHelper.getWishListRoute(action: RouteAction.pushReplacement);
            },
          )
            : Consumer<WishListController>(builder: (context, wishListProvider, child) {
          return wishListProvider.wishList != null
            ? wishListProvider.wishList!.isNotEmpty
            ? RefreshIndicator(
            onRefresh: () async => await  wishListProvider.getWishList(),
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '${wishListProvider.wishList!.length} ',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  TextSpan(text: getTranslated('saved_products', context) ?? '',
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                ])),
              )),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 268,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => FadeSlideIn(
                      index: index < 6 ? index : 6,
                      child: WishListWidget(wishlistModel: wishListProvider.wishList?[index], index: index),
                    ),
                    childCount: wishListProvider.wishList!.length,
                  ),
                ),
              ),
            ]))
            : const NoInternetOrDataScreenWidget(isNoInternet: false, message: 'no_wishlist_product', icon: Images.noWishlist)
            : const WishListShimmer();
          })),
        ]),
      ),
    );
  }
}


