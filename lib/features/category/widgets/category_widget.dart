import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/category/domain/models/category_model.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
/// Edge length of a home category tile.
double categoryTileSize(BuildContext context) =>
    (MediaQuery.of(context).size.width / 4.4).clamp(64.0, 110.0);

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final int length;
  const CategoryWidget({super.key, required this.category, required this.index, required this.length});

  @override
  Widget build(BuildContext context) {
    final double size = categoryTileSize(context);

    return Padding(padding: EdgeInsetsDirectional.only(
        start: index == 0 ? Dimensions.homePagePadding : 12,
        end: index + 1 == length ? Dimensions.homePagePadding : 0),
      child: FadeSlideIn(
        index: index,
        offset: const Offset(18, 0),
        child: Column( children: [

          // Gradient ring around a frosted tile.
          Container(
            height: size, width: size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPalette.primaryLight.withValues(alpha: .9),
                  AppPalette.secondary.withValues(alpha: .35),
                ],
              ),
              boxShadow: [BoxShadow(
                color: AppPalette.primary.withValues(alpha: .14),
                blurRadius: 14, offset: const Offset(0, 6),
              )],
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white.withValues(alpha: .92),
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(21),
                child: CustomImageWidget(image: '${category.imageFullUrl?.path}', fit: BoxFit.cover)),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeEight),
          Center(child: SizedBox(width: size + 4,
              child: Text(category.name??'', textAlign: TextAlign.center, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color))))]),
      ),
    );
  }
}
