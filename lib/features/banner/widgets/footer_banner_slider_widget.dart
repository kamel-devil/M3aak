import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/domain/models/banner_model.dart';
import 'package:kk_thotix_m3aak/features/banner/widgets/banners_widget.dart';
import 'package:provider/provider.dart';

class FooterBannerSliderWidget extends StatelessWidget {
  const FooterBannerSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, bannerProvider, child) {
        List<BannerModel> bannerList = [];

        if((bannerProvider.footerBannerList?.length ?? 0) > 1) {
          bannerList = bannerProvider.footerBannerList?.sublist(1) ?? [];
        }

        if(bannerList.isEmpty) {
          return const SizedBox();
        }

        return PharmacyBannerCarousel(
          banners: bannerList,
          currentIndex: bannerProvider.footerBannerIndex ?? 0,
          onPageChanged: bannerProvider.onChangeFooterBannerIndex,
        );
      },
    );
  }
}
