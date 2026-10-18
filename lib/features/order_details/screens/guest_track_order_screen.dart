import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/auth_ui.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/helper/velidate_check.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

class GuestTrackOrderScreen extends StatefulWidget {
  const GuestTrackOrderScreen({super.key});

  @override
  State<GuestTrackOrderScreen> createState() => _GuestTrackOrderScreenState();
}

class _GuestTrackOrderScreenState extends State<GuestTrackOrderScreen> {
  TextEditingController orderIdController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: getTranslated('TRACK_ORDER', context)),
        body: Consumer<OrderDetailsController>(
            builder: (context, orderTrackingProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge),
            child: Form(
              key: formKey,
              child:
                  ListView(physics: const ClampingScrollPhysics(), children: [
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                AuthIllustration(
                  icon: Icons.local_shipping_rounded,
                  title: getTranslated('where_is_my_order', context) ?? '',
                  description: Text(getTranslated(
                      'enter_your_order_id_and_phone_number_to_get_delivery_updates', context)!),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                AuthFormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AuthFieldLabel(getTranslated('order_id', context) ?? ''),
                CustomTextFieldWidget(
                  controller: orderIdController,
                  prefixIcon: Images.orderIdIcon,
                  prefixColor: Theme.of(context).primaryColor,
                  isAmount: true,
                  inputType: TextInputType.phone,
                  hintText: getTranslated('enter_order_id', context),
                  showLabelText: false,
                  validator: (value) => ValidateCheck.validateEmptyText(
                      value, 'order_id_is_required'),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomButton(
                  isLoading: orderTrackingProvider.searching,
                  buttonText: '${getTranslated('track_order', context)}',
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    String orderId = orderIdController.text.trim();
                    // String phone = phoneNumberController.text.trim();

                    if (formKey.currentState?.validate() ?? false) {
                      await orderTrackingProvider
                          .trackOrder(
                              orderId: orderId.toString(),
                              phoneNumber: '',
                              isUpdate: true)
                          .then((value) {
                        if (value.response?.statusCode == 200) {
                          if (context.mounted) {
                            RouterHelper.getOrderDetailsScreenRoute(
                              action: RouteAction.push,
                              orderId: int.parse(orderIdController.text.trim()),
                              phone: '',
                            );
                          }
                        }
                      });
                    }
                  },
                ),
                ])),
              ]),
            ),
          );
        }));
  }
}
