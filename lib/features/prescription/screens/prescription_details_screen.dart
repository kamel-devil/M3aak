import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/prescription/controllers/prescription_controller.dart';
import 'package:kk_thotix_m3aak/features/prescription/domain/models/prescription_model.dart';
import 'package:kk_thotix_m3aak/features/prescription/widgets/prescription_status_chip.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class PrescriptionDetailsScreen extends StatelessWidget {
  final PrescriptionModel prescription;
  const PrescriptionDetailsScreen({super.key, required this.prescription});

  String _date() {
    final DateTime? parsed = DateTime.tryParse(prescription.createdAt ?? '')?.toLocal();
    return parsed == null ? '' : DateFormat('d MMM yyyy, h:mm a').format(parsed);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(getTranslated('delete_prescription', ctx) ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(getTranslated('cancel', ctx) ?? '')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(getTranslated('delete', ctx) ?? '', style: const TextStyle(color: AppPalette.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final bool ok = await Provider.of<PrescriptionController>(context, listen: false).delete(prescription.id!);
      if (ok && context.mounted) Navigator.pop(context);
    }
  }

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InteractiveViewer(child: CustomImageWidget(image: url, fit: BoxFit.contain)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = PrescriptionStatusStyle.of(prescription.status);
    final bool hasResponse = (prescription.adminNote ?? '').isNotEmpty;
    final bool hasNotes = (prescription.notes ?? '').isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(title: '${getTranslated('prescription', context)} #${prescription.id}'),
      bottomNavigationBar: prescription.isPending
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppPalette.error),
                  label: Text(getTranslated('delete_prescription', context) ?? '', style: textBold.copyWith(color: AppPalette.error)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: AppPalette.error.withValues(alpha: .5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          FadeSlideIn(
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: style.color.withValues(alpha: .14), borderRadius: BorderRadius.circular(16)),
                  child: Icon(style.icon, color: style.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    PrescriptionStatusChip(status: prescription.status),
                    const SizedBox(height: 6),
                    Text(_date(), style: textRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor)),
                  ]),
                ),
              ]),
            ),
          ),
          if (hasResponse) ...[
            const SizedBox(height: 14),
            FadeSlideIn(
              index: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .3), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(getTranslated('pharmacist_response', context) ?? '',
                        style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                  ]),
                  const SizedBox(height: 10),
                  Text(prescription.adminNote!, style: textRegular.copyWith(color: Colors.white, height: 1.7)),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 2,
            child: Text(getTranslated('prescription_images', context) ?? '', style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            index: 3,
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              for (final url in prescription.imageUrls)
                PressableScale(
                  onTap: () => _openImage(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomImageWidget(image: url, width: 104, height: 104),
                  ),
                ),
            ]),
          ),
          if (hasNotes) ...[
            const SizedBox(height: 18),
            FadeSlideIn(
              index: 4,
              child: Text(getTranslated('notes', context) ?? '', style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              index: 5,
              child: GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                radius: 18,
                child: Text(prescription.notes!, style: textRegular.copyWith(height: 1.7)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
