import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/domain/models/banner_model.dart';
import 'package:kk_thotix_m3aak/features/banner/widgets/banner_shimmer.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:provider/provider.dart';

/// Hero banner carousel. Banner artwork already carries its own copy, so the
/// image is shown clean; a caption only appears when the banner has a title.
class BannersWidget extends StatelessWidget {
  const BannersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, bannerProvider, child) {
        final mainBanners = bannerProvider.mainBannerList;

        if (mainBanners == null) {
          return const BannerShimmer();
        }

        if (mainBanners.isEmpty) {
          return const SizedBox();
        }

        return PharmacyBannerCarousel(
          banners: mainBanners,
          currentIndex: bannerProvider.currentIndex ?? 0,
          onPageChanged: bannerProvider.setCurrentIndex,
        );
      },
    );
  }
}

/// Shared banner carousel used by the hero and footer sliders.
class PharmacyBannerCarousel extends StatelessWidget {
  const PharmacyBannerCarousel({
    super.key,
    required this.banners,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<BannerModel> banners;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
        final BannerController bannerProvider =
            Provider.of<BannerController>(context, listen: false);
        final List<BannerModel> mainBanners = banners;
        final double width = MediaQuery.of(context).size.width;
        final double bannerHeight = width * .46;

        return Column(
          children: [
            SizedBox(
              height: bannerHeight + 16,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: bannerHeight + 16,
                  viewportFraction: .9,
                  autoPlay: mainBanners.length > 1,
                  enableInfiniteScroll: mainBanners.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.easeInOutCubic,
                  pauseAutoPlayOnTouch: true,
                  enlargeCenterPage: true,
                  enlargeFactor: .08,
                  onPageChanged: (index, reason) => onPageChanged(index),
                ),
                itemCount: mainBanners.length,
                itemBuilder: (context, index, _) {
                  final banner = mainBanners[index];
                  final bool hasCaption = banner.title?.isNotEmpty ?? false;
                  final bool hasButton = banner.buttonText?.isNotEmpty ?? false;

                  return PressableScale(
                    scale: .98,
                    haptic: false,
                    onTap: () {
                      if (banner.resourceId != null || banner.url != null) {
                        bannerProvider.clickBannerRedirect(
                          context,
                          banner.resourceId,
                          banner.resourceType == 'product' ? banner.product : null,
                          banner.resourceType,
                          url: banner.url,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppPalette.softShadow(context),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(fit: StackFit.expand, children: [
                          ColoredBox(
                            color: AppPalette.tint(context),
                            child: CustomImageWidget(
                              image: '${banner.photoFullUrl?.path}',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Thin glass rim.
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: .35), width: 1.2),
                            ),
                          ),
                          if (hasCaption || hasButton)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppPalette.primaryDeep.withValues(alpha: .75),
                                    ],
                                  ),
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (hasCaption)
                                          Text(banner.title!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textBold.copyWith(
                                                  color: Colors.white, fontSize: 16)),
                                        if (banner.subTitle?.isNotEmpty ?? false)
                                          Text(banner.subTitle!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textRegular.copyWith(
                                                  color: Colors.white.withValues(alpha: .9),
                                                  fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  if (hasButton)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(banner.buttonText!,
                                          style: textBold.copyWith(
                                              color: AppPalette.primaryDeep, fontSize: 12)),
                                    ),
                                ]),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (mainBanners.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mainBanners.length, (index) {
                  final bool isActive = index == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 22 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isActive ? AppPalette.brandGradient : null,
                      color: isActive
                          ? null
                          : Theme.of(context).primaryColor.withValues(alpha: .22),
                    ),
                  );
                }),
              ),
          ],
        );
  }
}
