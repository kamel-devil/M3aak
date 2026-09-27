import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/create_account_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

class ShippingDetailsWidget extends StatefulWidget {
  final bool hasPhysical;
  final bool billingAddress;
  final GlobalKey<FormState> passwordFormKey;

  const ShippingDetailsWidget(
      {super.key,
      required this.hasPhysical,
      required this.billingAddress,
      required this.passwordFormKey});

  @override
  State<ShippingDetailsWidget> createState() => _ShippingDetailsWidgetState();
}

class _ShippingDetailsWidgetState extends State<ShippingDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    bool isGuestMode =
        !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    return Consumer<CheckoutController>(
        builder: (context, shippingProvider, _) {
      if (shippingProvider.sameAsBilling && !widget.hasPhysical) {
        shippingProvider.setSameAsBilling();
      }
      return Consumer<AddressController>(
          builder: (context, locationProvider, _) {
        final int? selectedAddressIndex = shippingProvider.addressIndex;
        final bool hasSelectedAddress = selectedAddressIndex != null &&
            (locationProvider.addressList?.length ?? 0) > selectedAddressIndex;
        final selectedAddress = hasSelectedAddress
            ? locationProvider.addressList![selectedAddressIndex]
            : null;

        return Container(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            widget.hasPhysical
                ? Card(
                    child: Container(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: 18,
                                              child: Image.asset(
                                                  Images.deliveryTo)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Text(
                                              '${getTranslated('delivery_to', context)}',
                                              style: textMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        RouterHelper.getSavedAddressListRoute(
                                            fromGuest: isGuestMode);
                                      },
                                      child: SizedBox(
                                          width: 20,
                                          child: Image.asset(
                                            Images.edit,
                                            scale: 3,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                    ),
                                  ]),
                              const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        (!hasSelectedAddress)
                                            ? '${getTranslated('address_type', context)}'
                                            : selectedAddress!.addressType!
                                                .capitalize(),
                                        style: textRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color),
                                        maxLines: 3,
                                        overflow: TextOverflow.fade),
                                    const Divider(thickness: .200),
                                    (!hasSelectedAddress)
                                        ? InkWell(
                                            onTap: () {
                                              RouterHelper
                                                  .getSavedAddressListRoute(
                                                      fromGuest: isGuestMode);
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      right: Dimensions
                                                          .paddingSizeSmall),
                                                  child: Icon(
                                                      Icons
                                                          .add_circle_outline_outlined,
                                                      size: 20,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                Text(
                                                    getTranslated(
                                                            'add_your_address',
                                                            context) ??
                                                        '',
                                                    style: titilliumRegular
                                                        .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.fade),
                                              ],
                                            ),
                                          )
                                        : Column(children: [
                                            AddressInfoItem(
                                                icon: Images.user,
                                                title: selectedAddress
                                                        ?.contactPersonName ??
                                                    ''),
                                            AddressInfoItem(
                                                icon: Images.callIcon,
                                                title: selectedAddress?.phone ??
                                                    ''),
                                            AddressInfoItem(
                                                icon: Images.address,
                                                title:
                                                    selectedAddress?.address ??
                                                        ''),
                                          ])
                                  ]),
                            ])))
                : const SizedBox(),
            if (widget.hasPhysical)
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeExtraSmall,
                  left: Dimensions.paddingSizeSmall,
                  right: Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: Dimensions.fontSizeDefault,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withValues(alpha: 0.65),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Expanded(
                      child: Text(
                        'يمكنك تعديل عنوان التوصيل من خلال أيقونة التعديل بالأعلى.',
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
                height: widget.hasPhysical ? Dimensions.paddingSizeSmall : 0),

            isGuestMode
                ? (widget.hasPhysical)
                    ? CreateAccountWidget(formKey: widget.passwordFormKey)
                    : const SizedBox()
                : const SizedBox(),

            isGuestMode
                ? const SizedBox(height: Dimensions.paddingSizeSmall)
                : const SizedBox(),

            // if (widget.hasPhysical && widget.billingAddress)
            //   Padding(
            //     padding: EdgeInsets.only(
            //         bottom:
            //             widget.hasPhysical ? Dimensions.paddingSizeSmall : 0),
            //     child: InkWell(
            //       highlightColor: Colors.transparent,
            //       focusColor: Colors.transparent,
            //       splashColor: Colors.transparent,
            //       onTap: () => shippingProvider.setSameAsBilling(),
            //       child:
            //           Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            //         SizedBox(
            //             width: 20,
            //             height: 20,
            //             child: Container(
            //                 alignment: Alignment.center,
            //                 decoration: BoxDecoration(
            //                     border: Border.all(
            //                         color: Theme.of(context)
            //                             .primaryColor
            //                             .withValues(alpha: .75),
            //                         width: 1.5),
            //                     borderRadius: BorderRadius.circular(6)),
            //                 child: Icon(CupertinoIcons.checkmark_alt,
            //                     size: 15,
            //                     color: shippingProvider.sameAsBilling
            //                         ? Theme.of(context)
            //                             .primaryColor
            //                             .withValues(alpha: .75)
            //                         : Colors.transparent))),
            //         Padding(
            //             padding: const EdgeInsets.symmetric(
            //                 horizontal: Dimensions.paddingSizeSmall),
            //             child: Text(getTranslated('same_as_delivery', context)!,
            //                 style: textRegular.copyWith(
            //                     fontSize: Dimensions.fontSizeDefault,
            //                     color: Theme.of(context)
            //                         .textTheme
            //                         .bodyLarge
            //                         ?.color)))
            //       ]),
            //     ),
            //   ),

            // if(widget.billingAddress && !shippingProvider.sameAsBilling)
            // Card(child: Container(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
            //       color: Theme.of(context).cardColor),
            //     child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
            //       Row(mainAxisAlignment:MainAxisAlignment.start, crossAxisAlignment:CrossAxisAlignment.start, children: [
            //         Expanded(
            //           child: Row(
            //             children: [
            //               SizedBox(width: 18, child: Image.asset(Images.billingTo)),
            //               Padding(
            //                 padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            //                 child: Text(
            //                   '${getTranslated('billing_to', context)}',
            //                   style: textMedium.copyWith(
            //                     fontSize: Dimensions.fontSizeLarge,
            //                     color: Theme.of(context).textTheme.bodyLarge?.color,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //
            //
            //         InkWell(
            //           onTap: () => RouterHelper.getSavedBillingAddressListRoute(fromGuest: isGuestMode),
            //           child: SizedBox(width: 20,child: Image.asset(Images.edit, scale: 3, color: Theme.of(context).primaryColor,)),
            //         ),]),
            //
            //
            //         const SizedBox(height: Dimensions.paddingSizeDefault,),
            //       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //
            //         if(shippingProvider.billingAddressIndex != null && (locationProvider.addressList?.isNotEmpty ?? false)
            //           && locationProvider.addressList![shippingProvider.billingAddressIndex!].addressType != null
            //           && locationProvider.addressList![shippingProvider.billingAddressIndex!].addressType != '')
            //
            //         Text((shippingProvider.billingAddressIndex != null && (locationProvider.addressList?.isNotEmpty ?? false))
            //           ? locationProvider.addressList![shippingProvider.billingAddressIndex!].addressType!.capitalize()
            //           : '${getTranslated('address_type', context)}',
            //
            //           style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
            //           maxLines: 1, overflow: TextOverflow.fade,
            //         ),
            //         const Divider(thickness: .200),
            //
            //         (shippingProvider.billingAddressIndex != null && (locationProvider.addressList?.isNotEmpty ?? false))
            //             ? Column(children: [
            //           AddressInfoItem(icon: Images.user,
            //               title: locationProvider.addressList?[shippingProvider.billingAddressIndex!].contactPersonName??''),
            //           AddressInfoItem(icon: Images.callIcon,
            //               title: locationProvider.addressList?[shippingProvider.billingAddressIndex!].phone??''),
            //           AddressInfoItem(icon: Images.address,
            //               title: locationProvider.addressList?[shippingProvider.billingAddressIndex!].address??''),
            //         ]) :  Text(getTranslated('add_your_address', context)!,
            //           style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
            //           maxLines: 3, overflow: TextOverflow.fade,
            //         ),
            //       ]),
            //     ]),
            //   )),

            // if (widget.billingAddress && shippingProvider.sameAsBilling)
            //   Card(
            //       child: Container(
            //     padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            //     decoration: BoxDecoration(
            //         borderRadius:
            //             BorderRadius.circular(Dimensions.paddingSizeDefault),
            //         color: Theme.of(context).cardColor),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Expanded(
            //                 child: Row(
            //                   children: [
            //                     SizedBox(
            //                         width: 18,
            //                         child: Image.asset(Images.billingTo)),
            //                     Padding(
            //                       padding: const EdgeInsets.symmetric(
            //                           horizontal:
            //                               Dimensions.paddingSizeExtraSmall),
            //                       child: Row(
            //                         children: [
            //                           Text(
            //                             '${getTranslated('billing_to', context)}',
            //                             style: textMedium.copyWith(
            //                                 fontSize: Dimensions.fontSizeLarge),
            //                           ),
            //                           const SizedBox(
            //                               width: Dimensions.paddingSizeSmall),
            //                           Text(
            //                             '(${getTranslated("same_as_delivery", context)})',
            //                             style: textMedium.copyWith(
            //                               fontSize: Dimensions.fontSizeDefault,
            //                               color: Theme.of(context)
            //                                   .hintColor
            //                                   .withValues(alpha: .75),
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ]),
            //       ],
            //     ),
            //   )),

            isGuestMode
                ? (!widget.hasPhysical)
                    ? CreateAccountWidget(formKey: widget.passwordFormKey)
                    : const SizedBox()
                : const SizedBox(),
          ]),
        );
      });
    });
  }
}

class AddressInfoItem extends StatelessWidget {
  final String? icon;
  final String? title;

  const AddressInfoItem({super.key, this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(children: [
        SizedBox(width: 18, child: Image.asset(icon!)),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                child: Text(title ?? '',
                    style: textRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    maxLines: 2,
                    overflow: TextOverflow.fade)))
      ]),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
