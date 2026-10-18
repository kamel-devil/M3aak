import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/product_details/controllers/product_details_controller.dart';
import 'package:kk_thotix_m3aak/features/review/controllers/review_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Segmented "Specification | Reviews" switch with a sliding gradient pill.
class ReviewAndSpecificationSectionWidget extends StatelessWidget {
  final double? averageReview;
  const ReviewAndSpecificationSectionWidget({
    super.key,
    this.averageReview
  });

  @override
  Widget build(BuildContext context) {
    final bool showReviews = (averageReview ?? 0) > 0;

    return Consumer<ProductDetailsController>(
      builder: (context, controller, _) {
        final bool reviewSelected = controller.isReviewSelected && showReviews;

        return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppPalette.tint(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 44,
              child: LayoutBuilder(builder: (context, constraints) {
                final int count = showReviews ? 2 : 1;
                final double segment = constraints.maxWidth / count;
                final bool rtl = Directionality.of(context) == TextDirection.rtl;
                final double offset = reviewSelected ? segment : 0;

                return Stack(children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: rtl ? null : offset,
                    right: rtl ? offset : null,
                    top: 0,
                    bottom: 0,
                    width: segment,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.primaryDeep.withValues(alpha: .12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(children: [
                    _Segment(
                      label: getTranslated('description', context) ?? '',
                      icon: Icons.description_outlined,
                      selected: !reviewSelected,
                      onTap: () => controller.selectReviewSection(false),
                    ),
                    if (showReviews)
                      _Segment(
                        label: getTranslated('reviews', context) ?? '',
                        icon: Icons.star_outline_rounded,
                        selected: reviewSelected,
                        onTap: () => controller.selectReviewSection(true),
                        badge: Consumer<ReviewController>(
                          builder: (context, reviewController, _) => Text(
                            '${reviewController.reviewList?.length ?? 0}',
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ]),
                ]);
              }),
            ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppPalette.primaryDeep : Theme.of(context).hintColor;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: color),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: badge,
            ),
          ],
        ]),
      ),
    );
  }
}
