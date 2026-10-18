import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_loggedin_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/prescription/controllers/prescription_controller.dart';
import 'package:kk_thotix_m3aak/features/prescription/domain/models/prescription_model.dart';
import 'package:kk_thotix_m3aak/features/prescription/widgets/prescription_status_chip.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<PrescriptionController>(context, listen: false).getPrescriptions(1);
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = Provider.of<PrescriptionController>(context, listen: false);
    final list = controller.prescriptionList;
    if (list == null || controller.isLoading) return;
    final int total = list.totalSize ?? 0;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        list.prescriptions.length < total) {
      controller.getPrescriptions((list.offset ?? 1) + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('prescriptions', context)),
      bottomNavigationBar: loggedIn
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: .96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
                ),
                child: PressableScale(
                  onTap: () => RouterHelper.getUploadPrescriptionRoute(action: RouteAction.push),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.upload_file_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(getTranslated('upload_prescription', context) ?? '',
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                    ]),
                  ),
                ),
              ),
            )
          : null,
      body: !loggedIn
          ? NotLoggedInWidget(
              fromPage: RouterHelper.prescriptionListScreen,
              onLoginSuccess: () => RouterHelper.getPrescriptionListRoute(action: RouteAction.pushReplacement),
            )
          : Consumer<PrescriptionController>(builder: (context, controller, _) {
              final list = controller.prescriptionList;
              if (list == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.prescriptions.isEmpty) {
                return NoInternetOrDataScreenWidget(
                  isNoInternet: false,
                  icon: null,
                  message: 'no_prescriptions_yet',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.getPrescriptions(1),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: list.prescriptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => FadeSlideIn(
                    index: index,
                    child: _PrescriptionCard(prescription: list.prescriptions[index]),
                  ),
                ),
              );
            }),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final PrescriptionModel prescription;
  const _PrescriptionCard({required this.prescription});

  String _date() {
    final DateTime? parsed = DateTime.tryParse(prescription.createdAt ?? '')?.toLocal();
    return parsed == null ? '' : DateFormat('d MMM yyyy, h:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final style = PrescriptionStatusStyle.of(prescription.status);
    final bool hasResponse = (prescription.adminNote ?? '').isNotEmpty;

    return PressableScale(
      onTap: () => RouterHelper.getPrescriptionDetailsRoute(prescription: prescription, action: RouteAction.push),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        radius: 22,
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 72,
              height: 72,
              child: prescription.imageUrls.isEmpty
                  ? Container(color: style.color.withValues(alpha: .12), child: Icon(Icons.description_rounded, color: style.color))
                  : CustomImageWidget(image: prescription.imageUrls.first, width: 72, height: 72),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('${getTranslated('prescription', context)} #${prescription.id}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                ),
                PrescriptionStatusChip(status: prescription.status),
              ]),
              const SizedBox(height: 6),
              Text(_date(), style: textRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor)),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.photo_library_outlined, size: 14, color: Theme.of(context).hintColor),
                const SizedBox(width: 4),
                Text('${prescription.imageUrls.length}', style: textRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor)),
                if (hasResponse) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.mark_chat_read_rounded, size: 14, color: AppPalette.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(getTranslated('pharmacist_response', context) ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: textMedium.copyWith(fontSize: 12, color: AppPalette.primary)),
                  ),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
