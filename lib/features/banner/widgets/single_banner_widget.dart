import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/domain/models/banner_model.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:provider/provider.dart';

/// Single promotional banner. Artwork of any shape (wide promos, square
/// logos, tall side-bar art) is shown whole on a blurred "ambient" copy of
/// itself, so it never leaves big white gaps or gets cropped.
class SingleBannersWidget extends StatelessWidget {
  final BannerModel? bannerModel;
  final double? height;
  final bool noRadius;
  const SingleBannersWidget({super.key, this.bannerModel, this.height, this.noRadius = false});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    // Side-bar art comes in very tall; keep it to a comfortable card height.
    final double effectiveHeight = math.min(height ?? width / 2.2, width * .62);
    final double radius = noRadius ? 0 : 24;
    final String image = '${bannerModel?.photoFullUrl?.path}';

    return PressableScale(
      scale: .98,
      haptic: false,
      onTap: () => Provider.of<BannerController>(context, listen: false).clickBannerRedirect(
        context,
        bannerModel?.resourceId,
        bannerModel?.resourceType == 'product' ? bannerModel?.product : null,
        bannerModel?.resourceType,
      ),
      child: Container(
        height: effectiveHeight,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: noRadius ? null : AppPalette.softShadow(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(fit: StackFit.expand, children: [
            // Ambient blurred backdrop.
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Transform.scale(
                scale: 1.3,
                child: CustomImageWidget(image: image, fit: BoxFit.cover),
              ),
            ),
            ColoredBox(color: Colors.white.withValues(alpha: AppPalette.isDark(context) ? .05 : .25)),
            // Full artwork.
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(math.max(radius - 8, 0)),
                child: CustomImageWidget(image: image, fit: BoxFit.contain),
              ),
            ),
            if (!noRadius)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: Colors.white.withValues(alpha: .4), width: 1.2),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
