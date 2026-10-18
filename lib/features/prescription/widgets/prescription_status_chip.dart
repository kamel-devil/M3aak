import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';

class PrescriptionStatusStyle {
  final Color color;
  final IconData icon;
  const PrescriptionStatusStyle(this.color, this.icon);

  static PrescriptionStatusStyle of(String? status) {
    switch (status) {
      case 'under_review':
        return const PrescriptionStatusStyle(AppPalette.info, Icons.manage_search_rounded);
      case 'accepted':
        return const PrescriptionStatusStyle(AppPalette.success, Icons.check_circle_rounded);
      case 'rejected':
        return const PrescriptionStatusStyle(AppPalette.error, Icons.cancel_rounded);
      case 'completed':
        return const PrescriptionStatusStyle(AppPalette.primary, Icons.verified_rounded);
      default:
        return const PrescriptionStatusStyle(AppPalette.warning, Icons.hourglass_top_rounded);
    }
  }
}

class PrescriptionStatusChip extends StatelessWidget {
  final String? status;
  const PrescriptionStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = PrescriptionStatusStyle.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(style.icon, size: 14, color: style.color),
        const SizedBox(width: 5),
        Text(getTranslated('prescription_${status ?? 'pending'}', context) ?? '',
            style: textMedium.copyWith(fontSize: 12, color: style.color)),
      ]),
    );
  }
}
