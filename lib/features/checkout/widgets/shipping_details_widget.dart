import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/checkout_ui.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/create_account_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
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
    bool isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    return Consumer<CheckoutController>(builder: (context, shippingProvider, _) {
      if (shippingProvider.sameAsBilling && !widget.hasPhysical) {
        shippingProvider.setSameAsBilling();
      }
      return Consumer<AddressController>(builder: (context, locationProvider, _) {
        final int? selectedAddressIndex = shippingProvider.addressIndex;
        final bool hasSelectedAddress = selectedAddressIndex != null &&
            (locationProvider.addressList?.length ?? 0) > selectedAddressIndex;
        final selectedAddress = hasSelectedAddress ? locationProvider.addressList![selectedAddressIndex] : null;
        void openAddresses() => RouterHelper.getSavedAddressListRoute(fromGuest: isGuestMode);

        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (widget.hasPhysical)
            CheckoutCard(
              icon: Icons.local_shipping_outlined,
              title: getTranslated('delivery_to', context),
              trailing: hasSelectedAddress ? CheckoutChangeButton(onTap: openAddresses) : null,
              child: hasSelectedAddress
                  ? _SelectedAddress(
                      type: selectedAddress!.addressType ?? '',
                      isBilling: selectedAddress.isBilling ?? false,
                      name: selectedAddress.contactPersonName ?? '',
                      phone: selectedAddress.phone ?? '',
                      address: selectedAddress.address ?? '',
                    )
                  : _AddAddressButton(onTap: openAddresses),
            ),

          if (isGuestMode) ...[
            if (widget.hasPhysical) const SizedBox(height: 14),
            CreateAccountWidget(formKey: widget.passwordFormKey),
          ],
        ]);
      });
    });
  }
}

class _SelectedAddress extends StatelessWidget {
  final String type;
  final bool isBilling;
  final String name;
  final String phone;
  final String address;
  const _SelectedAddress({required this.type, required this.isBilling, required this.name, required this.phone, required this.address});

  @override
  Widget build(BuildContext context) {
    final String lower = type.toLowerCase();
    final bool isOffice = lower.contains('office') || lower.contains('work');
    final bool isHome = lower.contains('home') || lower.contains('permanent');
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final String typeLabel = getTranslated(lower, context) ?? (type.isEmpty ? '' : type.capitalize());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppPalette.tint(context), borderRadius: BorderRadius.circular(18)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: isOffice
                ? const LinearGradient(colors: [AppPalette.secondary, Color(0xFF1F6FC0)])
                : AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(isOffice ? Icons.work_outline_rounded : isHome ? Icons.home_rounded : Icons.location_on_rounded,
              color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(typeLabel, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(getTranslated(isBilling ? 'billing_address' : 'shipping_address', context) ?? '',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: AppPalette.primaryDeep)),
            ),
          ]),
          const SizedBox(height: 4),
          if (name.isNotEmpty || phone.isNotEmpty)
            Text([name, phone].where((e) => e.isNotEmpty).join('  ·  '),
                style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: textColor)),
          const SizedBox(height: 2),
          Text(address, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall + 1, height: 1.5, color: Theme.of(context).hintColor)),
        ])),
      ]),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: Theme.of(context).primaryColor.withValues(alpha: .5)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(color: AppPalette.tint(context), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(getTranslated('add_delivery_address', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault + 1, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 2),
            Text(getTranslated('add_delivery_address_hint', context) ?? '', textAlign: TextAlign.center,
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          ]),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20));
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class AddressInfoItem extends StatelessWidget {
  final String? icon;
  final String? title;

  const AddressInfoItem({super.key, this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(children: [
        SizedBox(width: 18, child: Image.asset(icon!)),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text(title ?? '',
                    style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
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
