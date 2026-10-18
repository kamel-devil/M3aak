import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/order/controllers/order_controller.dart';
import 'package:kk_thotix_m3aak/features/order/widgets/order_shimmer_widget.dart';
import 'package:kk_thotix_m3aak/features/order/widgets/order_type_button_widget.dart';
import 'package:kk_thotix_m3aak/features/order/widgets/order_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_loggedin_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/paginated_list_view_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/whatsapp_support_button_widget.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromDashboard;
  const OrderScreen({super.key, this.isBacButtonExist = true, this.fromDashboard = false}) ;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ScrollController scrollController  = ScrollController();
   bool isGuestMode = !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn();
  @override
  void initState() {
    if(!isGuestMode){
      Provider.of<OrderController>(context, listen: false).setIndex(0, notify: false);
      Provider.of<OrderController>(context, listen: false).getOrderList(1,'ongoing');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: CustomAppBar(title: getTranslated('order', context), isBackButtonExist: widget.isBacButtonExist),
     bottomNavigationBar: Consumer<SplashController>(
       builder: (context, configProvider, _) {
         return Padding(
           padding: EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
               Dimensions.paddingSizeDefault, widget.fromDashboard ? 100 : Dimensions.paddingSizeDefault),
           child: WhatsAppSupportButton(
             phoneNumber: configProvider.configModel?.companyPhone ?? '',
             orderDetails: 'السلام عليكم\n\n📦 استفسار عن الطلب:\n━━━━━━━━━━━━━━━━\nأحتاج إلى مساعدة بخصوص طلبي\nأو الحصول على تحديثات عن حالة الطلب\n\nشكراً لدعمكم المميز',
           ),
         );
       },
     ),
     body: isGuestMode ? NotLoggedInWidget(message: getTranslated('to_view_the_order_history', context), fromPage: widget.fromDashboard ? '${RouterHelper.dashboardScreen}?page=orders' : RouterHelper.orderScreen, ) :
      Consumer<OrderController>(
        builder: (context, orderController, child) {
          return Column(children: [


            Padding(
              padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
              child: Column(children: [
                if (orderController.orderTypeIndex == 0 &&
                    (orderController.orderModel?.orders?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall + 2),
                    child: _RunningSummary(
                      count: orderController.orderModel?.totalSize ??
                          orderController.orderModel!.orders!.length,
                    ),
                  ),
                const OrderStatusTabs(),
              ]),
            ),



              Expanded(child: orderController.orderModel != null ? (orderController.orderModel!.orders != null &&
                  orderController.orderModel!.orders!.isNotEmpty)?
                SingleChildScrollView(
                  controller: scrollController,
                  child: PaginatedListView(scrollController: scrollController,
                    onPaginate: (int? offset) async{
                      await orderController.getOrderList(offset!, orderController.selectedType);
                    },
                    totalSize: orderController.orderModel?.totalSize,
                    offset: orderController.orderModel?.offset != null ? int.parse(orderController.orderModel!.offset!):1,
                    itemView: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderController.orderModel?.orders!.length,
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      itemBuilder: (context, index) => FadeSlideIn(
                        index: index,
                        child: OrderWidget(orderModel: orderController.orderModel?.orders![index]),
                      ),
                    ),
                  ),
                ) : const _EmptyOrders() :
                  const OrderShimmerWidget()
              )

            ],
          );
        }
      ),
    );
  }
}

/// Gradient card summarising how many orders are on their way.
class _RunningSummary extends StatelessWidget {
  const _RunningSummary({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppPalette.brandGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppPalette.primaryDeep.withValues(alpha: .28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .45)),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getTranslated('orders_in_progress', context) ?? '',
                  style: textRegular.copyWith(
                      color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall + 1)),
              Text('$count ${getTranslated('orders', context)}',
                  style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge + 2)),
            ]),
          ),
          PressableScale(
            onTap: () => RouterHelper.getGuestTrackOrderRoute(action: RouteAction.push),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(getTranslated('TRACK_ORDER', context) ?? '',
                  style: textBold.copyWith(color: AppPalette.primaryDeep, fontSize: Dimensions.fontSizeSmall + 1)),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Friendly empty state with a shortcut back to shopping.
class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 48, Dimensions.paddingSizeDefault, 24),
      child: FadeSlideIn(
        child: GlassContainer(
          blur: false,
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(children: [
            Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppPalette.tint(context),
                  AppPalette.tint(context).withValues(alpha: .35),
                ]),
              ),
              child: PulseGlow(
                radius: 24,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppPalette.brandGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(getTranslated('no_orders_yet', context) ?? '',
                textAlign: TextAlign.center,
                style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge + 2,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            Text(getTranslated('no_orders_yet_hint', context) ?? '',
                textAlign: TextAlign.center,
                style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault, height: 1.6, color: Theme.of(context).hintColor)),
            const SizedBox(height: 20),
            PressableScale(
              onTap: () => RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppPalette.primary.withValues(alpha: .32), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Text(getTranslated('shop_now', context) ?? '',
                    style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
