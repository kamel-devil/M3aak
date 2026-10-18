import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/widget/how_to_use_dialog_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/filter_icon_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/paginated_list_view_widget.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/transaction_shimmer.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/domain/models/loyalty_point_model.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/widget/loyalty_filter_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/widget/loyalty_point_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_loggedin_widget.dart';
import 'package:kk_thotix_m3aak/features/home/screens/home_screens.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/widget/loyalty_point_info_widget.dart';
import 'package:provider/provider.dart';

class LoyaltyPointScreen extends StatefulWidget {
  const LoyaltyPointScreen({super.key});
  @override
  State<LoyaltyPointScreen> createState() => _LoyaltyPointScreenState();
}

class _LoyaltyPointScreenState extends State<LoyaltyPointScreen> {
  final ScrollController scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<LoyaltyPointController>(context, listen: false).getLoyaltyPointList(context, 1, isUpdate: false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(
        title: getTranslated('loyalty_point', context),
        showResetIcon: true,
        reset: Padding(
          padding: const EdgeInsetsDirectional.only(end: 14),
          child: IconButton(
            tooltip: getTranslated('how_to_use', context),
            icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).primaryColor),
            onPressed: () => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => const HowToUseDialogWidget(),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(color: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async => Provider.of<LoyaltyPointController>(context, listen: false).getLoyaltyPointList(context,1),
        child: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverToBoxAdapter(child: LoyaltyPointInfoWidget()),

              SliverPersistentHeader(pinned: true, delegate: SliverDelegate(
                height: 60,
                child: Container(
                  height: 60, // Explicit height matching the delegate
                  color: Theme.of(context).canvasColor.withValues(alpha: .92),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.homePagePadding,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Container(width: 4, height: 18, margin: const EdgeInsetsDirectional.only(end: 8),
                            decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(4))),
                        Text(
                          '${getTranslated('point_history', context)}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ]),

                      Selector<LoyaltyPointController, LoyaltyPointModel?>(
                        selector: (context, loyaltyController) => loyaltyController.loyaltyPointModel,
                        builder: (context, loyaltyPointModel, _) {
                          return FilterIconWidget(
                            filterCount: _getFilterCount(loyaltyPointModel),
                            onTap: loyaltyPointModel == null
                                ? null
                                : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (builder) => const LoyaltyFilterBottomSheetWidget(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                    ),
                  ),
                ),
              )),

            ];
          },
          body: isGuestMode ? NotLoggedInWidget(fromPage: RouterHelper.loyaltyPointScreen) : Consumer<LoyaltyPointController>(
            builder: (context, loyaltyPointController, _) {
              return (loyaltyPointController.loyaltyPointModel?.loyaltyPointList?.isNotEmpty ?? false) ? PaginatedListView(
                scrollController: scrollController,
                onPaginate: (int? offset)=> loyaltyPointController.getLoyaltyPointList(
                  context, offset ?? 1,
                  startDate: loyaltyPointController.loyaltyPointModel?.startDate,
                  endDate: loyaltyPointController.loyaltyPointModel?.endDate,
                  filterBy: loyaltyPointController.loyaltyPointModel?.filterBy,
                  transactionTypes: loyaltyPointController.loyaltyPointModel?.transactionTypes,
                ),
                totalSize: loyaltyPointController.loyaltyPointModel?.totalSize,
                offset: loyaltyPointController.loyaltyPointModel?.offset,
                limit: loyaltyPointController.loyaltyPointModel?.limit ,
                itemView: Expanded(child: ListView.builder(
                  itemCount: loyaltyPointController.loyaltyPointModel?.loyaltyPointList?.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (ctx,index){
                    return LoyaltyPointWidget(
                      loyaltyPointModel: loyaltyPointController.loyaltyPointModel?.loyaltyPointList?[index],
                      isLastItem: index + 1 == loyaltyPointController.loyaltyPointModel?.loyaltyPointList?.length,
                    );
                  },
                )),
              ) : (loyaltyPointController.loyaltyPointModel?.loyaltyPointList?.isEmpty ?? false) ? NoInternetOrDataScreenWidget(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
                isNoInternet: false, icon: Images.noTransactionIcon, message: 'no_transaction_history',
              ) : const TransactionShimmer();
            }
          ),
        ),
      ),

    );
  }

  int _getFilterCount(LoyaltyPointModel? loyaltyPointModel) {
    if (loyaltyPointModel == null) return 0;

    final int nonNullFiltersCount = [
      loyaltyPointModel.filterBy,
      loyaltyPointModel.startDate,

    ].whereType<Object>().length;

    final int transactionTypesCount = loyaltyPointModel.transactionTypes?.length ?? 0;

    return nonNullFiltersCount + transactionTypesCount;
  }

}
