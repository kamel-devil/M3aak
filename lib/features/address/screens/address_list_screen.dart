import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/address/widgets/address_shimmer.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/features/address/widgets/remove_address_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});
  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AddressController>(context, listen: false).getAddressList(all: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('addresses', context)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: PressableScale(
            onTap: () => RouterHelper.getAddNewAddressRoute(isBilling: false),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppPalette.brandGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(getTranslated('add_new_address', context) ?? '',
                    style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
              ]),
            ),
          ),
        ),
      ),
      body: Consumer<AddressController>(
        builder: (context, locationProvider, child) {
          return locationProvider.addressList != null ? locationProvider.addressList!.isNotEmpty ?
          RefreshIndicator(onRefresh: () async => await locationProvider.getAddressList(),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: locationProvider.addressList?.length,
              itemBuilder: (context, index) {
                return AddressItemWidget(locationProvider: locationProvider, index: index);
              },
            ),
          ) :
          const NoInternetOrDataScreenWidget(isNoInternet: false,
            message: 'no_address_found',
            icon: Images.noAddress,
          ) : const AddressShimmerWidget();
        },
      ),
    );
  }
}

class AddressItemWidget extends StatelessWidget {
  const AddressItemWidget({
    super.key, required this.locationProvider, required this.index,
  });

  final AddressController locationProvider;
  final int index;

  @override
  Widget build(BuildContext context) {
    final address = locationProvider.addressList![index];
    final String rawType = address.addressType ?? '';
    final String type = rawType.toLowerCase();
    final bool isOffice = type.contains('office') || type.contains('work');
    final bool isHome = type.contains('home') || type.contains('permanent');
    final IconData icon = isOffice ? Icons.work_outline_rounded : isHome ? Icons.home_rounded : Icons.location_on_rounded;
    final Color color = isOffice ? AppPalette.secondary : isHome ? AppPalette.primary : AppPalette.accent;
    final String typeLabel = rawType.isEmpty ? '' : '${rawType[0].toUpperCase()}${rawType.substring(1)}';
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    Widget chip(String label, String value) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.tint(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(TextSpan(children: [
        TextSpan(text: '$label  ', style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
        TextSpan(text: value, style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
      ])),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: FadeSlideIn(
        index: index,
        child: GlassContainer(
          blur: false,
          radius: 24,
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: .75)]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(typeLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (address.isBilling ?? false)
                          ? getTranslated('billing_address', context) ?? ''
                          : getTranslated('shipping_address', context) ?? '',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: color),
                    ),
                  ),
                ]),
              ),

              _AddressAction(
                icon: Icons.edit_outlined,
                color: Theme.of(context).primaryColor,
                label: getTranslated('edit', context) ?? '',
                onTap: () => RouterHelper.getAddNewAddressRoute(
                  isBilling: address.isBilling,
                  address: address,
                  isEnableUpdate: true,
                ),
              ),
              const SizedBox(width: 8),
              _AddressAction(
                icon: Icons.delete_outline_rounded,
                color: AppPalette.error,
                label: getTranslated('delete', context) ?? '',
                onTap: () => showModalBottomSheet(backgroundColor: Colors.transparent, context: context, builder: (_) =>
                    RemoveFromAddressBottomSheet(addressId: address.id!, index: index)),
              ),
            ]),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppPalette.tint(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(address.address ?? '', style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1, height: 1.5, color: textColor,
                ))),
              ]),
            ),

            if ((address.city ?? '').isNotEmpty || (address.zip ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if ((address.city ?? '').isNotEmpty) chip(getTranslated('city', context) ?? '', address.city!),
                if ((address.zip ?? '').isNotEmpty) chip(getTranslated('zip', context) ?? '', address.zip!),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class _AddressAction extends StatelessWidget {
  const _AddressAction({required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: PressableScale(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
