import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/filter_icon_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_loggedin_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/paginated_list_view_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/home/screens/aster_theme_home_screen.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/transaction_shimmer.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/wallet/controllers/wallet_controller.dart';
import 'package:kk_thotix_m3aak/features/wallet/domain/models/wallet_transaction_model.dart';
import 'package:kk_thotix_m3aak/features/wallet/widgets/transaction_widget.dart';
import 'package:kk_thotix_m3aak/features/wallet/widgets/wallet_bonus_widget.dart';
import 'package:kk_thotix_m3aak/features/wallet/widgets/wallet_card_widget.dart';
import 'package:kk_thotix_m3aak/features/wallet/widgets/wallet_filter_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';


class WalletScreen extends StatefulWidget {
  final bool isBacButtonExist;
  const WalletScreen({super.key, this.isBacButtonExist = true});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final tooltipController = JustTheController();
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();


  final ScrollController scrollController = ScrollController();
  final bool darkMode = Provider.of<ThemeController>(Get.context!, listen: false).darkTheme;
  final bool isGuestMode = !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn();

  @override
  void initState() {
    super.initState();

    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<WalletController>(context, listen: false).getTransactionList(1, isUpdate: false);
      Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      Provider.of<WalletController>(context, listen: false).getWalletBonusBannerList();

    }
  }

  @override
  void dispose() {
    super.dispose();

    tooltipController.dispose();
    inputAmountController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: getTranslated('wallet', context)),
      body: RefreshIndicator(
      color: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).primaryColor,
      onRefresh: () async {
        Provider.of<WalletController>(context, listen: false).getTransactionList(1);
      },
      child: CustomScrollView(controller: scrollController, slivers: [

        SliverToBoxAdapter(child: Column(children: [

          isGuestMode
              ? NotLoggedInWidget(message: getTranslated('to_view_the_wishlist', context), fromPage: RouterHelper.walletScreen)
              : Column(children: [
            Consumer<WalletController>(builder: (context, walletP,_) {
              return Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .30), blurRadius: 30, offset: const Offset(0, 14))],
                    ),
                    child: WalletCardWidget(
                      tooltipController: tooltipController, focusNode: focusNode,
                      inputAmountController: inputAmountController,
                    ),
                  ));
            }),

            if(Provider.of<SplashController>(context, listen: false).configModel?.addFundsToWallet == 1)
            const WalletBonusWidget()

          ]),
        ])),


        SliverPersistentHeader(pinned: true, delegate: SliverDelegate(height: 64, child: Container(
          color: Theme.of(context).canvasColor.withValues(alpha: .92),
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeLarge,),
            Consumer<WalletController>(builder: (context, walletController, child) {
              return Padding(padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: Dimensions.homePagePadding),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(width: 4, height: 18, margin: const EdgeInsetsDirectional.only(end: 8),
                        decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(4))),
                    Text('${getTranslated('wallet_history', context)}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color:  Theme.of(context).textTheme.bodyLarge?.color),),
                  ]),

                  FilterIconWidget(
                    filterCount: _getFilterCount(walletController.walletTransactionModel),
                    onTap: walletController.walletTransactionModel == null ? null : (){
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_)=> const WalletFilterBottomSheetWidget()
                      );
                    },
                  ),

                ]),
              );
            }),
          ]),
        ))),

        SliverToBoxAdapter(
          child: isGuestMode ? const NotLoggedInWidget(fromPage: RouterHelper.walletScreen) : Consumer<WalletController>(
              builder: (context, walletController, _) {
                return (walletController.walletTransactionModel?.walletTransactionList?.isNotEmpty ?? false) ?  PaginatedListView(
                  scrollController: scrollController,
                  onPaginate: (int? offset) async => walletController.getTransactionList(
                    offset ?? 1,
                    startDate: walletController.walletTransactionModel?.startDate,
                    endDate: walletController.walletTransactionModel?.endDate,
                    filterBy: walletController.walletTransactionModel?.filterBy,
                    transactionTypes: walletController.walletTransactionModel?.transactionTypes,
                  ),
                  totalSize: walletController.walletTransactionModel?.totalSize,
                  offset: walletController.walletTransactionModel?.offset,
                  itemView: RepaintBoundary(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: walletController.walletTransactionModel?.walletTransactionList?.length,
                      itemBuilder: (ctx,index){
                        return TransactionWidget(
                          transactionModel: walletController.walletTransactionModel?.walletTransactionList?[index],
                          isLastIndex: index + 1 == walletController.walletTransactionModel?.walletTransactionList?.length,
                        );
                      },
                    ),
                  ),
                ) : (walletController.walletTransactionModel?.walletTransactionList?.isEmpty ?? false) ?
                const NoInternetOrDataScreenWidget(
                  padding: EdgeInsets.only(top: 50),
                  isNoInternet: false, message: 'no_transaction_history', icon: Images.noTransactionIcon,
                ) : const TransactionShimmer();
              }
          ),
        ),
      ]),
    ));
  }

  int _getFilterCount(WalletTransactionModel? walletTransactionModel) {
    if (walletTransactionModel == null) return 0;

    final int nonNullFiltersCount = [
      walletTransactionModel.filterBy,
      walletTransactionModel.startDate,
    ].whereType<Object>().length;

    final int transactionTypesCount = walletTransactionModel.transactionTypes?.length ?? 0;

    return nonNullFiltersCount + transactionTypesCount;
  }
}






