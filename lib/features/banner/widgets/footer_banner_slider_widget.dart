import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/domain/models/banner_model.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:provider/provider.dart';

class FooterBannerSliderWidget extends StatelessWidget {
  const FooterBannerSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Consumer<BannerController>(
      builder: (context, bannerProvider, child) {
        List<BannerModel> bannerList = [];

        if((bannerProvider.footerBannerList?.length ?? 0) > 1) {
          bannerList = bannerProvider.footerBannerList?.sublist(1) ?? [];
        }

        if(bannerList.isEmpty) {
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
                    autoPlay: bannerList.length > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 700),
                    pauseAutoPlayOnTouch: true,
                    pauseAutoPlayOnManualNavigate: true,
                    pauseAutoPlayInFiniteScroll: true,
                    enlargeFactor: .12,
                    enlargeCenterPage: true,
                    disableCenter: true,
                    onPageChanged: (index, reason) {
                      Provider.of<BannerController>(context, listen: false).onChangeFooterBannerIndex(index);
                    },
                  ),
                  itemCount: bannerList.length,
                  itemBuilder: (context, index, _) {
                    final banner = bannerList[index];

                    return InkWell(
                      onTap: () {
                        if(banner.resourceId != null || banner.url != null) {
                          bannerProvider.clickBannerRedirect(
                            context,
                            banner.resourceId,
                            banner.resourceType =='product' ? banner.product : null,
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
                                color: Provider.of<ThemeController>(context, listen: false).darkTheme
                                    ? Theme.of(context).primaryColor.withValues(alpha: .12)
                                    : Theme.of(context).primaryColor.withValues(alpha: .06),
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
                                    Color(0x05000000),
                                    Color(0x00000000),
                                    Color(0xA0000000),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if((banner.title?.isNotEmpty ?? false))
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
                                        if((banner.subTitle?.isNotEmpty ?? false))
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              banner.subTitle!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: .9),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B4CF0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      banner.buttonText?.isNotEmpty == true ? banner.buttonText! : 'Shop now',
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
              if(bannerList.length > 1) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bannerList.length, (index) {
                    final isActive = index == bannerProvider.footerBannerIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      width: isActive ? 20 : 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isActive
                            ? const Color(0xFF5B4CF0)
                            : Theme.of(context).primaryColor.withValues(alpha: .22),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
