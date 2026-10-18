import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/prescription/controllers/prescription_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  const UploadPrescriptionScreen({super.key});

  @override
  State<UploadPrescriptionScreen> createState() => _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<PrescriptionController>(context, listen: false).clearPicked();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      showCustomSnackBar(getTranslated('please_login_to_send_prescription', context), context);
      RouterHelper.getLoginRoute(
        fromPage: RouterHelper.uploadPrescriptionScreen,
        onLoginSuccess: () {
          if (mounted) _submit();
        },
      );
      return;
    }
    final bool ok = await Provider.of<PrescriptionController>(context, listen: false).submit(_notesController.text);
    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('upload_prescription', context)),
      bottomNavigationBar: Consumer<PrescriptionController>(builder: (context, controller, _) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: .96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
            ),
            child: PressableScale(
              onTap: controller.isSubmitting ? null : _submit,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: controller.isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(getTranslated('send_prescription', context) ?? '',
                              style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                        ]),
                ),
              ),
            ),
          ),
        );
      }),
      body: Consumer<PrescriptionController>(builder: (context, controller, _) {
        final images = controller.pickedImages;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            FadeSlideIn(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.medical_information_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(getTranslated('upload_prescription_hint', context) ?? '',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.6)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              index: 1,
              child: Text('${getTranslated('prescription_images', context)} (${images.length}/${PrescriptionController.maxImages})',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              index: 2,
              child: Wrap(spacing: 10, runSpacing: 10, children: [
                for (int i = 0; i < images.length; i++) _PickedTile(path: images[i].path, onRemove: () => controller.removeImage(i)),
                if (images.length < PrescriptionController.maxImages) ...[
                  _AddTile(icon: Icons.photo_camera_rounded, label: getTranslated('camera', context) ?? '', onTap: () => controller.pickImages(fromCamera: true)),
                  _AddTile(icon: Icons.photo_library_rounded, label: getTranslated('gallery', context) ?? '', onTap: () => controller.pickImages()),
                ],
              ]),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              index: 3,
              child: Text(getTranslated('notes', context) ?? '', style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              index: 4,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                radius: 18,
                child: TextField(
                  controller: _notesController,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                    hintText: getTranslated('prescription_notes_hint', context),
                    hintStyle: textRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          color: AppPalette.tint(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.primary.withValues(alpha: .35)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppPalette.primary, size: 28),
          const SizedBox(height: 6),
          Text(label, style: textMedium.copyWith(color: AppPalette.primary, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _PickedTile extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _PickedTile({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: kIsWeb ? Image.network(path, fit: BoxFit.cover) : Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        PositionedDirectional(
          top: 4,
          end: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: AppPalette.error, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
            ),
          ),
        ),
      ]),
    );
  }
}
