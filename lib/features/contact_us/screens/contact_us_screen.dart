import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/contact_us/controllers/contact_us_controller.dart';
import 'package:kk_thotix_m3aak/features/contact_us/domain/models/contact_us_body.dart';
import 'package:kk_thotix_m3aak/helper/velidate_check.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:provider/provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(context, listen: false).setCountryCode(CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel!.countryCode!).dialCode!, notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: true,title: '${getTranslated('contact_us', context)}'),
      body: Consumer<AuthController>(
        builder: (context, authProvider, _) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
            child: SingleChildScrollView(child: Form(
              key: contactFormKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),
                const _ContactHero(),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                FadeSlideIn(index: 1, child: GlassContainer(
                  blur: false,
                  radius: 26,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(getTranslated('send_us_a_message', context) ?? '',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                CustomTextFieldWidget(
                  prefixIcon: Images.user,
                  controller: fullNameController,
                  required: true,
                  labelText: getTranslated('full_name', context),
                  hintText: getTranslated('enter_full_name', context),
                  validator: (value)=> ValidateCheck.validateEmptyText(value, 'name_is_required'),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextFieldWidget(
                  hintText: getTranslated('email', context),
                    prefixIcon: Images.email,
                    required: true,
                    labelText: getTranslated('email', context),
                    controller: emailController,
                  validator: (value) =>ValidateCheck.validateEmail(value),

                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),


                CustomTextFieldWidget(
                    hintText: getTranslated('enter_mobile_number', context),
                    labelText: getTranslated('enter_mobile_number', context),
                    controller: phoneController,
                    required: true,
                    showCodePicker: true,
                    countryDialCode: authProvider.countryDialCode,
                    onCountryChanged: (CountryCode countryCode) {
                      authProvider.countryDialCode = countryCode.dialCode!;
                      authProvider.setCountryCode(countryCode.dialCode!);
                    },
                    isAmount: true,
                    inputAction: TextInputAction.next,
                    inputType: TextInputType.phone,
                  validator: (value)=> ValidateCheck.validateEmptyText(value, 'phone_is_required'),

                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),


                CustomTextFieldWidget(
                  required: true,
                  labelText: getTranslated('subject', context),
                  hintText: getTranslated('subject', context),
                  controller: subjectController,
                  validator: (value)=> ValidateCheck.validateEmptyText(value, 'subject_is_required'),

                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),


                CustomTextFieldWidget(maxLines: 5,
                    required: true,
                    controller: messageController,
                    labelText: getTranslated('message', context),
                    hintText: getTranslated('message', context),
                  validator: (value)=> ValidateCheck.validateEmptyText(value, 'message_is_required'),

                ),
                  ]),
                )),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],),
            )),
          );
        }
      ),
      bottomNavigationBar: Consumer<ContactUsController>(
        builder: (context, profileProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CustomButton(
              isLoading: profileProvider.isLoading,
              buttonText: getTranslated('send_request', context),
              onTap: (){
                if(contactFormKey.currentState?.validate() ?? false) {

                  String name = fullNameController.text.trim();
                  String email = emailController.text.trim();
                  String phone = phoneController.text.trim();
                  String subject = subjectController.text.trim();
                  String message = messageController.text.trim();

                  ContactUsBody contactUsBody = ContactUsBody(name: name, email: email, phone: phone, subject: subject, message: message);

                   profileProvider.contactUs(contactUsBody).then((isSuccess){
                     if(isSuccess) {
                       Navigator.of(Get.context!).pop();
                     }
                  });
                }
              },
            ),
          );
        }
      ),
    );
  }
}

/// Gradient card with one-tap call, WhatsApp and email shortcuts.
class _ContactHero extends StatelessWidget {
  const _ContactHero();

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<SplashController>(context, listen: false).configModel;
    final String phone = config?.companyPhone ?? '';
    final String email = config?.companyEmail ?? '';
    final String digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    Widget action(IconData icon, String label, VoidCallback? onTap, {bool solid = false}) {
      return Expanded(
        child: PressableScale(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            decoration: BoxDecoration(
              color: solid ? Colors.white : Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(18),
              border: solid ? null : Border.all(color: Colors.white.withValues(alpha: .4)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 22, color: solid ? const Color(0xFF128C4A) : Colors.white),
              const SizedBox(height: 4),
              Text(label, style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall,
                  color: solid ? const Color(0xFF128C4A) : Colors.white)),
            ]),
          ),
        ),
      );
    }

    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppPalette.brandGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .28), blurRadius: 28, offset: const Offset(0, 12))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getTranslated('we_are_here_to_help', context) ?? '',
              style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge + 2)),
          const SizedBox(height: 2),
          Text(getTranslated('contact_hero_subtitle', context) ?? '',
              style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall + 1)),
          const SizedBox(height: 14),
          Row(children: [
            action(Icons.call_rounded, getTranslated('call', context) ?? '',
                digits.isEmpty ? null : () => _open(Uri.parse('tel:+$digits'))),
            const SizedBox(width: 8),
            action(Icons.chat_rounded, 'WhatsApp',
                digits.isEmpty ? null : () => _open(Uri.parse('https://wa.me/$digits')), solid: true),
            const SizedBox(width: 8),
            action(Icons.mail_outline_rounded, getTranslated('email', context) ?? '',
                email.isEmpty ? null : () => _open(Uri.parse('mailto:$email'))),
          ]),
        ]),
      ),
    );
  }
}
