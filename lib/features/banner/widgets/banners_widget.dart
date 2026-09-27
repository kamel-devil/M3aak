import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/widgets/banner_shimmer.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/utill/color_resources.dart';
import 'package:provider/provider.dart';

class BannersWidget extends StatelessWidget {
  const BannersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, bannerProvider, child) {
        final mainBanners = bannerProvider.mainBannerList;
        final width = MediaQuery.of(context).size.width;
        final Color brandColor = Theme.of(context).primaryColor;

        if (mainBanners == null) {
          return const BannerShimmer();
        }

        if (mainBanners.isEmpty) {
          return const SizedBox();
        }

        return SizedBox(
          height: width * 0.52,
          child: Column(
            children: [
              SizedBox(
                height: width * 0.42,
                width: width,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    viewportFraction: 0.9,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 700),
                    pauseAutoPlayOnTouch: true,
                    pauseAutoPlayOnManualNavigate: true,
                    pauseAutoPlayInFiniteScroll: true,
                    enlargeFactor: .12,
                    enlargeCenterPage: true,
                    disableCenter: true,
                    onPageChanged: (index, reason) {
                      Provider.of<BannerController>(context, listen: false)
                          .setCurrentIndex(index);
                    },
                  ),
                  itemCount: mainBanners.length,
                  itemBuilder: (context, index, _) {
                    final banner = mainBanners[index];
                    return InkWell(
                      onTap: () {
                        if (banner.resourceId != null || banner.url != null) {
                          bannerProvider.clickBannerRedirect(
                            context,
                            banner.resourceId,
                            banner.resourceType == 'product'
                                ? banner.product
                                : null,
                            banner.resourceType,
                            url: banner.url,
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Provider.of<ThemeController>(context,
                                            listen: false)
                                        .darkTheme
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: .12)
                                    : Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: .06),
                              ),
                              child: CustomImageWidget(
                                image: '${banner.photoFullUrl?.path}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    ColorResources.bannerOverlayTop,
                                    Colors.transparent,
                                    ColorResources.bannerOverlayBottom,
                                  ],
                                  stops: [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 14,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if ((banner.title?.isNotEmpty ?? false))
                                          Text(
                                            banner.title!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              height: 1.2,
                                            ),
                                          ),
                                        if ((banner.subTitle?.isNotEmpty ??
                                            false))
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              banner.subTitle!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: .9),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: brandColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      banner.buttonText?.isNotEmpty == true
                                          ? banner.buttonText!
                                          : 'Shop now',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mainBanners.length, (index) {
                  final isActive = index == bannerProvider.currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 20 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isActive
                          ? brandColor
                          : brandColor.withValues(alpha: .22),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
