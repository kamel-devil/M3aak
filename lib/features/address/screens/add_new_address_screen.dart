import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/success_dialog_widget.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/address/domain/models/address_model.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/location/controllers/location_controller.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/config_model.dart'
    as config;
import 'package:kk_thotix_m3aak/helper/country_code_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/helper/velidate_check.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final bool? isBilling;
  const AddNewAddressScreen(
      {super.key,
      this.isEnableUpdate = false,
      this.address,
      this.fromCheckout = false,
      this.isBilling});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonEmailController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _cityController =
      TextEditingController(text: 'cairo');
  final TextEditingController _zipCodeController =
      TextEditingController(text: '00000');
  final TextEditingController _countryCodeController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _cityNode = FocusNode();
  final FocusNode _zipNode = FocusNode();
  GoogleMapController? _controller;
  CameraPosition? _cameraPosition;
  bool _updateAddress = true;
  Address? _address;
  String zip = '', country = 'IN';
  late LatLng _defaut;

  final GlobalKey<FormState> _addressFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    config.DefaultLocation? dLocation =
        Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.defaultLocation;
    _defaut = LatLng(double.parse(dLocation?.lat ?? '0'),
        double.parse(dLocation?.lng ?? '0'));

    if (widget.isBilling!) {
      _address = Address.billing;
    } else {
      _address = Address.shipping;
    }

    Provider.of<AuthController>(context, listen: false).setCountryCode(
        CountryCode.fromCountryCode(
                Provider.of<SplashController>(context, listen: false)
                    .configModel!
                    .countryCode!)
            .dialCode!,
        notify: false);
    _countryCodeController.text = CountryCode.fromCountryCode(
                Provider.of<SplashController>(context, listen: false)
                    .configModel!
                    .countryCode!)
            .name ??
        'Bangladesh';
    Provider.of<AddressController>(context, listen: false).getAddressType();
    Provider.of<AddressController>(context, listen: false)
        .getRestrictedDeliveryCountryList();
    Provider.of<AddressController>(context, listen: false)
        .getRestrictedDeliveryZipList();

    _checkPermission(
        () => Provider.of<LocationController>(context, listen: false)
            .getCurrentLocation(context, true, mapController: _controller),
        context);
    if (widget.isEnableUpdate && widget.address != null) {
      _updateAddress = false;

      Provider.of<LocationController>(context, listen: false).updateMapPosition(
          CameraPosition(
              target: LatLng(
            (widget.address!.latitude != null &&
                    widget.address!.latitude != '0' &&
                    widget.address!.latitude != '')
                ? double.parse(widget.address!.latitude!)
                : _defaut.latitude,
            (widget.address!.longitude != null &&
                    widget.address!.longitude != '0' &&
                    widget.address!.longitude != '')
                ? double.parse(widget.address!.longitude!)
                : _defaut.longitude,
          )),
          true,
          widget.address!.address,
          context);
      _contactPersonNameController.text =
          '${widget.address?.contactPersonName}';
      _countryCodeController.text = '${widget.address?.country}';
      _contactPersonEmailController.text = '${widget.address?.email}';
      // _contactPersonNumberController.text = '${widget.address?.phone}';
      _cityController.text = '${widget.address?.city}';
      _zipCodeController.text = '${widget.address?.zip}';
      if (widget.address!.addressType == 'Home') {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(0, false);
      } else if (widget.address!.addressType == 'Workplace') {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(1, false);
      } else {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(2, false);
      }
      String countryCode =
          CountryCodeHelper.getCountryCode(widget.address?.phone ?? '')!;
      Provider.of<AuthController>(context, listen: false)
          .setCountryCode(countryCode, notify: false);
      String phoneNumberOnly = CountryCodeHelper.extractPhoneNumber(
          countryCode, widget.address?.phone ?? '');
      _contactPersonNumberController.text = phoneNumberOnly;
    } else {
      if (Provider.of<ProfileController>(context, listen: false)
              .userInfoModel !=
          null) {
        _contactPersonNameController.text =
            '${Provider.of<ProfileController>(context, listen: false).userInfoModel!.fName ?? ''}'
            ' ${Provider.of<ProfileController>(context, listen: false).userInfoModel!.lName ?? ''}';

        String countryCode = CountryCodeHelper.getCountryCode(
            Provider.of<ProfileController>(context, listen: false)
                    .userInfoModel!
                    .phone ??
                '')!;
        Provider.of<AuthController>(context, listen: false)
            .setCountryCode(countryCode, notify: false);
        String phoneNumberOnly = CountryCodeHelper.extractPhoneNumber(
            countryCode,
            Provider.of<ProfileController>(context, listen: false)
                    .userInfoModel!
                    .phone ??
                '');
        _contactPersonNumberController.text = phoneNumberOnly;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.isEnableUpdate
              ? getTranslated('update_address', context)
              : getTranslated('add_new_address', context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<AddressController>(
              builder: (context, addressController, child) {
                if (Provider.of<SplashController>(context, listen: false)
                            .configModel!
                            .deliveryCountryRestriction ==
                        1 &&
                    addressController.restrictedCountryList.isNotEmpty) {
                  _countryCodeController.text =
                      addressController.restrictedCountryList[0];
                }
                return Consumer<LocationController>(
                    builder: (context, locationController, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Form(
                      key: _addressFormKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeLarge),
                                child: CustomTextFieldWidget(
                                  required: true,
                                  prefixIcon: Images.user,
                                  labelText: getTranslated(
                                      'enter_contact_person_name', context),
                                  hintText: getTranslated(
                                      'enter_contact_person_name', context),
                                  inputType: TextInputType.name,
                                  controller: _contactPersonNameController,
                                  focusNode: _nameNode,
                                  nextFocus: _numberNode,
                                  inputAction: TextInputAction.next,
                                  capitalization: TextCapitalization.words,
                                  validator: (value) =>
                                      ValidateCheck.validateEmptyText(value,
                                          'contact_person_name_is_required'),
                                )),

                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            Consumer<AuthController>(
                                builder: (context, authProvider, _) {
                              return CustomTextFieldWidget(
                                required: true,
                                labelText: getTranslated('phone', context),
                                hintText: getTranslated(
                                    'enter_mobile_number', context),
                                controller: _contactPersonNumberController,
                                focusNode: _numberNode,
                                nextFocus: _emailNode,
                                showCodePicker: true,
                                countryDialCode: authProvider.countryDialCode,
                                onCountryChanged: (CountryCode countryCode) {
                                  authProvider.countryDialCode =
                                      countryCode.dialCode!;
                                  authProvider
                                      .setCountryCode(countryCode.dialCode!);
                                },
                                isAmount: true,
                                validator: (value) =>
                                    ValidateCheck.validateEmptyText(
                                        value, "phone_must_be_required"),
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.phone,
                              );
                            }),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            if (!Provider.of<AuthController>(context,
                                    listen: false)
                                .isLoggedIn())
                              CustomTextFieldWidget(
                                required: true,
                                prefixIcon: Images.email,
                                labelText: getTranslated('email', context),
                                hintText: getTranslated(
                                    'enter_contact_person_email', context),
                                inputType: TextInputType.emailAddress,
                                controller: _contactPersonEmailController,
                                focusNode: _emailNode,
                                nextFocus: _addressNode,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                validator: (value) =>
                                    ValidateCheck.validateEmail(value),
                              ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            Provider.of<SplashController>(context,
                                            listen: false)
                                        .configModel!
                                        .mapApiStatus ==
                                    1
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.width / 1.8,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: AppPalette.glassBorder(context), width: 1.5),
                                      boxShadow: AppPalette.softShadow(context),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            22),
                                        child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              GoogleMap(
                                                  mapType: MapType.normal,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                          target: widget
                                                                  .isEnableUpdate
                                                              ? LatLng(
                                                                  (widget.address!.latitude != null &&
                                                                          widget.address!.latitude !=
                                                                              '0' &&
                                                                          widget.address!.latitude !=
                                                                              '')
                                                                      ? double.parse(widget
                                                                          .address!
                                                                          .latitude!)
                                                                      : _defaut
                                                                          .latitude,
                                                                  (widget.address!.longitude != null &&
                                                                          widget.address!.longitude !=
                                                                              '0' &&
                                                                          widget.address!.longitude !=
                                                                              '')
                                                                      ? double.parse(widget
                                                                          .address!
                                                                          .longitude!)
                                                                      : _defaut
                                                                          .longitude,
                                                                )
                                                              : LatLng(
                                                                  locationController
                                                                      .position
                                                                      .latitude,
                                                                  locationController
                                                                      .position
                                                                      .longitude),
                                                          zoom: 16),
                                                  onTap: (latLng) {
                                                    RouterHelper
                                                        .getSelectLocationScreen(
                                                            googleMapController:
                                                                _controller,
                                                            action: RouteAction
                                                                .push);
                                                  },
                                                  zoomControlsEnabled: false,
                                                  compassEnabled: false,
                                                  indoorViewEnabled: true,
                                                  mapToolbarEnabled: false,
                                                  onCameraIdle: () {
                                                    if (_updateAddress) {
                                                      locationController
                                                          .updateMapPosition(
                                                              _cameraPosition,
                                                              true,
                                                              null,
                                                              context);
                                                    } else {
                                                      _updateAddress = true;
                                                    }
                                                  },
                                                  onCameraMove: ((position) =>
                                                      _cameraPosition =
                                                          position),
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) {
                                                    _controller = controller;
                                                    if (!widget
                                                            .isEnableUpdate &&
                                                        _controller != null) {
                                                      locationController
                                                          .getCurrentLocation(
                                                              context, true,
                                                              mapController:
                                                                  _controller);
                                                    }
                                                  }),
                                              locationController.loading
                                                  ? Center(
                                                      child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(Theme.of(
                                                                      context)
                                                                  .primaryColor)))
                                                  : const SizedBox(),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  alignment: Alignment.center,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 40,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  )),
                                              PositionedDirectional(
                                                  top: 10,
                                                  end: 0,
                                                  child: InkWell(
                                                      onTap: () => RouterHelper
                                                          .getSelectLocationScreen(
                                                              googleMapController:
                                                                  _controller,
                                                              action:
                                                                  RouteAction
                                                                      .push),
                                                      child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          margin: const EdgeInsetsDirectional
                                                              .only(
                                                              end: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    13),
                                                            color: Colors.white,
                                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 4))],
                                                          ),
                                                          child: Icon(
                                                              Icons.fullscreen,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              size: 20))))
                                            ])))
                                : const SizedBox(),

                            Padding(
                              padding: const EdgeInsets.only(top: 18, bottom: 10),
                              child: Text(getTranslated('label_us', context)!,
                                  style: textBold.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    fontSize: Dimensions.fontSizeLarge,
                                  )),
                            ),

                            Wrap(spacing: 8, runSpacing: 8, children: List.generate(
                              addressController.addressTypeList.length, (index) {
                                final bool selected = addressController.selectAddressIndex == index;
                                final type = addressController.addressTypeList[index];
                                return PressableScale(
                                  onTap: () => addressController.updateAddressIndex(index, true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    constraints: const BoxConstraints(minHeight: 44),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      gradient: selected ? AppPalette.brandGradient : null,
                                      color: selected ? null : AppPalette.glass(context),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: selected ? Colors.transparent : AppPalette.glassBorder(context)),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      SizedBox(width: 18, child: Image.asset(type.icon,
                                          color: selected ? Colors.white : Theme.of(context).primaryColor)),
                                      const SizedBox(width: 8),
                                      Text(getTranslated(type.title, context) ?? type.title,
                                          style: textBold.copyWith(
                                            color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                          )),
                                    ]),
                                  ),
                                );
                              },
                            )),

                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 18),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppPalette.tint(context),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(children: [
                                  for (final option in Address.values)
                                    Expanded(child: PressableScale(
                                      onTap: () => setState(() => _address = option),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 220),
                                        curve: Curves.easeOutCubic,
                                        height: 44,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _address == option ? Theme.of(context).cardColor : Colors.transparent,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [BoxShadow(
                                            color: Colors.black.withValues(alpha: _address == option ? .06 : 0),
                                            blurRadius: 10, offset: const Offset(0, 3),
                                          )],
                                        ),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(option == Address.shipping ? Icons.local_shipping_outlined : Icons.receipt_long_outlined,
                                              size: 18,
                                              color: _address == option ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                                          const SizedBox(width: 6),
                                          Flexible(child: Text(
                                            getTranslated(option == Address.shipping ? 'shipping_address' : 'billing_address', context) ?? '',
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: textBold.copyWith(
                                              fontSize: Dimensions.fontSizeSmall + 1,
                                              color: _address == option ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                            ),
                                          )),
                                        ]),
                                      ),
                                    )),
                                ]),
                              ),
                            ),

                            CustomTextFieldWidget(
                              labelText:
                                  getTranslated('delivery_address', context),
                              hintText: getTranslated('usa', context),
                              inputType: TextInputType.streetAddress,
                              inputAction: TextInputAction.next,
                              focusNode: _addressNode,
                              prefixIcon: Images.address,
                              required: true,
                              nextFocus: _cityNode,
                              controller: locationController.locationController,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, "address_is_required"),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            ...[
                              // Text(getTranslated('country', context)!, style: textRegular.copyWith(
                              //   color: Theme.of(context).hintColor,
                              //   fontSize: Dimensions.fontSizeSmall,
                              // )),
                              // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              // SizedBox(height: 60,
                              //     child: Consumer<AddressController>(
                              //         builder: (context, addressController, _) {
                              //           return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              //
                              //             Provider.of<SplashController>(context, listen: false).configModel!.deliveryCountryRestriction == 1?
                              //
                              //             Container(width: MediaQuery.of(context).size.width,
                              //               decoration: BoxDecoration(color: Theme.of(context).cardColor,
                              //                   borderRadius: BorderRadius.circular(5),
                              //                   border: Border.all(width: .1, color: Theme.of(context).hintColor.withValues(alpha:0.1))),
                              //               child: DropdownButtonFormField2<String>(
                              //                 isExpanded: true,
                              //                 isDense: true,
                              //                 decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              //
                              //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
                              //                 hint:  Row(children: [
                              //                   Image.asset(Images.country),
                              //                   const SizedBox(width: Dimensions.paddingSizeSmall),
                              //                   Text(_countryCodeController.text, style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
                              //                 ],
                              //                 ),
                              //                 items: addressController.restrictedCountryList.map((item) => DropdownMenuItem<String>(
                              //                     value: item, child: Text(item, style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)))).toList(),
                              //                 onChanged: (value) {
                              //                   _countryCodeController.text = value!;
                              //
                              //                 },
                              //                 buttonStyleData: const ButtonStyleData(padding: EdgeInsets.only(right: 8),),
                              //                 iconStyleData: IconStyleData(
                              //                     icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).hintColor), iconSize: 24),
                              //                 dropdownStyleData: DropdownStyleData(
                              //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),),),
                              //                 menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
                              //               ),
                              //             ):
                              //
                              //             Container(width: MediaQuery.of(context).size.width,
                              //               padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              //               decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                              //                   color: Theme.of(context).cardColor,
                              //                   border: Border.all(color: Theme.of(context).hintColor.withValues(alpha:.5))),
                              //               child: CodePickerWidget(
                              //                 fromCountryList: true,
                              //                 padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                              //                 flagWidth: 25,
                              //                 onChanged: (val){
                              //                   _countryCodeController.text = val.name!;
                              //                 },
                              //                 initialSelection: _countryCodeController.text,
                              //                 showDropDownButton: true,
                              //                 showCountryOnly: true,
                              //                 showOnlyCountryWhenClosed: true,
                              //                 showFlagDialog: true,
                              //                 hideMainText: false,
                              //                 showFlagMain: false,
                              //                 dialogBackgroundColor: Theme.of(context).cardColor,
                              //                 barrierColor: Provider.of<ThemeController>(context).darkTheme ? Colors.black.withValues(alpha:0.4) : null,
                              //                 textStyle: textRegular.copyWith(
                              //                   fontSize: Dimensions.fontSizeLarge,
                              //                   color: Theme.of(context).textTheme.bodyLarge!.color,
                              //                 ),
                              //                 dialogTextStyle: textRegular.copyWith(
                              //                   fontSize: Dimensions.fontSizeDefault,
                              //                   color: Theme.of(context).textTheme.bodyLarge!.color,
                              //                 ),
                              //               ),
                              //             ),
                              //
                              //           ]);})),
                            ],

                            // const SizedBox(height: Dimensions.paddingSizeDefaultAddress),
                            // CustomTextFieldWidget(
                            //   labelText: getTranslated('city', context),
                            //   hintText: getTranslated('city', context),
                            //   inputType: TextInputType.streetAddress,
                            //   inputAction: TextInputAction.next,
                            //   focusNode: _cityNode,
                            //   required: true,
                            //   nextFocus: _zipNode,
                            //   prefixIcon: Images.city,
                            //   controller: _cityController,
                            //   validator: (value)=> ValidateCheck.validateEmptyText(value, 'city_is_required'),
                            // ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            // Provider.of<SplashController>(context, listen: false).configModel!.deliveryZipCodeAreaRestriction == 0 ?
                            // CustomTextFieldWidget(
                            //   labelText: getTranslated('zip', context),
                            //   hintText: getTranslated('zip', context),
                            //   inputAction: TextInputAction.done,
                            //   focusNode: _zipNode,
                            //   required: true,
                            //   prefixIcon: Images.city,
                            //   controller: _zipCodeController,
                            //   validator: (value)=> ValidateCheck.validateEmptyText(value, 'zip_code_is_required'),
                            // ) :
                            // Container(width: MediaQuery.of(context).size.width,
                            //   decoration: BoxDecoration(color: Theme.of(context).cardColor,
                            //       borderRadius: BorderRadius.circular(5),
                            //       border: Border.all(width: .1, color: Theme.of(context).hintColor.withValues(alpha:0.1))),
                            //   child: DropdownButtonFormField2<String>(
                            //     isExpanded: true,
                            //     isDense: true,
                            //     decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
                            //     hint:  Row(children: [
                            //       Image.asset(Images.city),
                            //       const SizedBox(width: Dimensions.paddingSizeSmall,),
                            //       Text(getTranslated('zip', context)!, style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
                            //     ],
                            //     ),
                            //     items: addressController.restrictedZipList.map((item) => DropdownMenuItem<String>(
                            //         value: item.zipcode, child: Text(item.zipcode!, style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall)))).toList(),
                            //     onChanged: (value) {
                            //       _zipCodeController.text = value!;
                            //
                            //     },
                            //     buttonStyleData: const ButtonStyleData(padding: EdgeInsets.only(right: 8),),
                            //     iconStyleData: IconStyleData(
                            //         icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).hintColor), iconSize: 24),
                            //     dropdownStyleData: DropdownStyleData(
                            //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(5))),
                            //     menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
                            //   ),
                            // ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: CustomButton(
                                isLoading: addressController.isLoading,
                                buttonText: widget.isEnableUpdate
                                    ? getTranslated('update_address', context)
                                    : getTranslated('save_location', context),
                                onTap: locationController.loading
                                    ? null
                                    : () {
                                        if (_addressFormKey.currentState
                                                ?.validate() ??
                                            false) {
                                          AddressModel addressModel =
                                              AddressModel(
                                            addressType: addressController
                                                .addressTypeList[
                                                    addressController
                                                        .selectAddressIndex]
                                                .title,
                                            contactPersonName:
                                                _contactPersonNameController
                                                    .text,
                                            phone:
                                                '${Provider.of<AuthController>(context, listen: false).countryDialCode}${_contactPersonNumberController.text.trim()}',
                                            email: _contactPersonEmailController
                                                .text
                                                .trim(),
                                            city: _cityController.text,
                                            zip: _zipCodeController.text,
                                            country:
                                                _countryCodeController.text,
                                            guestId:
                                                Provider.of<AuthController>(
                                                        context,
                                                        listen: false)
                                                    .getGuestToken(),
                                            isBilling:
                                                _address == Address.billing,
                                            address: locationController
                                                .locationController.text,
                                            latitude: widget.isEnableUpdate
                                                ? locationController
                                                    .position.latitude
                                                    .toString()
                                                : locationController
                                                    .position.latitude
                                                    .toString(),
                                            longitude: widget.isEnableUpdate
                                                ? locationController
                                                    .position.longitude
                                                    .toString()
                                                : locationController
                                                    .position.longitude
                                                    .toString(),
                                          );

                                          if (widget.isEnableUpdate) {
                                            addressModel.id =
                                                widget.address!.id;
                                            addressController.updateAddress(
                                                context,
                                                addressModel: addressModel,
                                                addressId: addressModel.id);
                                          } else if (_countryCodeController.text
                                              .trim()
                                              .isEmpty) {
                                            showCustomSnackBar(
                                                '${getTranslated('country_is_required', context)}',
                                                context);
                                          } else {
                                            addressController
                                                .addAddress(addressModel)
                                                .then((value) {
                                              if (value.response?.statusCode ==
                                                  200) {
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                                if (widget.fromCheckout) {
                                                  if (context.mounted) {
                                                    Provider.of<CheckoutController>(
                                                            context,
                                                            listen: false)
                                                        .setAddressIndex(0);
                                                  }
                                                }
                                              }
                                            });
                                          }
                                        }
                                      },
                              ),
                            ),
                          ]),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.whileInUse) {
      InkWell(
          onTap: () async {
            Navigator.pop(context);
            await Geolocator.requestPermission();
            _checkPermission(callback, Get.context!);
          },
          child: AlertDialog(
              content: SuccessDialog(
                  icon: Icons.location_on_outlined,
                  title: '',
                  description: getTranslated('you_denied', Get.context!))));
    } else if (permission == LocationPermission.deniedForever) {
      InkWell(
          onTap: () async {
            if (context.mounted) {}
            Navigator.pop(context);
            await Geolocator.openAppSettings();
            _checkPermission(callback, Get.context!);
          },
          child: AlertDialog(
              content: SuccessDialog(
                  icon: Icons.location_on_outlined,
                  title: '',
                  description: getTranslated('you_denied', Get.context!))));
    } else {
      callback();
    }
  }
}

enum Address { shipping, billing }
