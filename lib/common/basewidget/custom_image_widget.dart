import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';


class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder = Images.placeholder});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholder?? Images.placeholder, height: height, width: width, fit: BoxFit.cover),
      imageUrl: image, fit: fit?? BoxFit.cover,
      height: height,width: width,
      memCacheWidth: _memCacheWidth(context),
      errorWidget: (c, o, s) => Image.asset(placeholder?? Images.placeholder, height: height, width: width, fit: BoxFit.cover),
    );
  }

  /// Decodes the image at (roughly) the size it is drawn at instead of the full source resolution,
  /// so list thumbnails don't hold multi-megabyte bitmaps in memory. Only the width is constrained
  /// (aspect ratio is preserved); the larger box side is used so BoxFit.cover stays sharp.
  int? _memCacheWidth(BuildContext context) {
    final double? w = width;
    if (w == null || !w.isFinite || w <= 0) {
      return null;
    }
    final double h = (height != null && height!.isFinite) ? height! : 0;
    final double devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    return (math.max(w, h) * devicePixelRatio).round();
  }
}
