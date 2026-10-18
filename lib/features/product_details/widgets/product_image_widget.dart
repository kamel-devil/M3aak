import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/pharmacy_product_parts.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/compare/controllers/compare_controller.dart';
import 'package:kk_thotix_m3aak/features/product_details/controllers/product_details_controller.dart';
import 'package:kk_thotix_m3aak/features/product_details/domain/models/product_details_model.dart';
import 'package:kk_thotix_m3aak/features/product_details/enums/preview_type.dart';
import 'package:kk_thotix_m3aak/features/product_details/screens/product_image_screen.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/audio_preview.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/download_preview_file.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/image_preview.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/video_preview.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/favourite_button_widget.dart';
import 'package:provider/provider.dart';

/// Product gallery: large frosted stage with swipeable images, floating
/// actions and a thumbnail strip.
class ProductImageWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final bool fromFlashDeals;
  ProductImageWidget({super.key, required this.productModel, required this.fromFlashDeals});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    if (productModel == null || productModel!.imagesFullUrl == null) {
      return const SizedBox();
    }
    final splashController = Provider.of<SplashController>(context, listen: false);
    final images = productModel!.imagesFullUrl!;
    final double stageHeight = MediaQuery.of(context).size.width * .86;
    final bool hasDiscount = (productModel?.discount ?? 0) > 0 ||
        (productModel?.clearanceSale?.discountAmount ?? 0) > 0;

    return Consumer<ProductDetailsController>(builder: (context, productController, _) {
      final int selected = productController.imageSliderIndex ?? 0;

      return Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.homePagePadding, Dimensions.paddingSizeSmall, Dimensions.homePagePadding, 0),
          child: GlassContainer(
            blur: false,
            radius: 30,
            padding: const EdgeInsets.all(10),
            color: AppPalette.isDark(context) ? AppPalette.darkGlass : Colors.white.withValues(alpha: .92),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: stageHeight - 20, child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(children: [
                // Images
                PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: productController.setImageSliderSelectedIndex,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      if (!(productModel!.productImagesNull ?? false)) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ProductImageScreen(
                            title: getTranslated('product_image', context),
                            imageList: images,
                          ),
                        ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                      child: CustomImageWidget(
                        image: '${images[index].path}',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Discount / flash badges
                PositionedDirectional(
                  top: 16,
                  start: 16,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (hasDiscount)
                      DiscountBadge(label: _discountLabel(context)),
                    if (fromFlashDeals) ...[
                      const SizedBox(height: 8),
                      Image.asset(Images.flashDeal, scale: 2.5),
                    ],
                  ]),
                ),

                // Floating actions
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: Column(children: [
                    FavouriteButtonWidget(
                      backgroundColor: Theme.of(context).cardColor,
                      productId: productModel?.id,
                      fromProductDetails: true,
                    ),
                    if (splashController.configModel!.activeTheme != "default") ...[
                      const SizedBox(height: 10),
                      Consumer<CompareController>(builder: (context, compare, _) {
                        final bool active = compare.compIds.contains(productModel!.id);
                        return _ActionCircle(
                          active: active,
                          onTap: () {
                            if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                              Provider.of<CompareController>(context, listen: false)
                                  .addCompareList(productModel!.id!);
                            } else {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) => const NotLoggedInBottomSheetWidget());
                            }
                          },
                          child: Image.asset(Images.compare,
                              color: active ? Colors.white : Theme.of(context).primaryColor),
                        );
                      }),
                    ],
                  ]),
                ),

                // Image counter
                if (images.length > 1)
                  PositionedDirectional(
                    bottom: 12,
                    start: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: .92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPalette.glassBorder(context)),
                      ),
                      child: Text('${selected + 1} / ${images.length}',
                          textDirection: TextDirection.ltr,
                          style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ),
                  ),

                // Digital preview
                if (productModel?.productType == 'digital' &&
                    productModel?.previewFileFullUrl != null &&
                    productModel?.previewFileFullUrl?.path != '')
                  PositionedDirectional(
                    end: 14,
                    bottom: 14,
                    child: PressableScale(
                      onTap: () => _showPreview(
                          productModel?.previewFileFullUrl?.path ?? '',
                          productModel?.name ?? '',
                          productModel?.previewFileFullUrl?.key ?? '',
                          context),
                      child: GlassContainer(
                        blur: false,
                        radius: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(Images.previewEyeIcon, width: 15),
                          const SizedBox(width: 6),
                          Text('${getTranslated('preview', context)}',
                              style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            )),

            // Thumbnails
            if (images.length > 1)
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool active = index == selected;
                    return PressableScale(
                      haptic: false,
                      onTap: () {
                        productController.setImageSliderSelectedIndex(index);
                        _controller.animateToPage(index,
                            duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppPalette.isDark(context) ? AppPalette.darkTint : AppPalette.tint(context),
                          border: Border.all(
                            color: active ? Theme.of(context).primaryColor : AppPalette.glassBorder(context),
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: active ? 1 : .7,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomImageWidget(image: '${images[index].path}', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 4),
      ]);
    });
  }

  String _discountLabel(BuildContext context) {
    final p = productModel!;
    return (p.clearanceSale?.discountAmount ?? 0) > 0
        ? PriceConverter.percentageCalculation(
            context, p.unitPrice, p.clearanceSale?.discountAmount, p.clearanceSale?.discountType)
        : PriceConverter.percentageCalculation(context, p.unitPrice, p.discount, p.discountType);
  }

  void _showPreview(String url, String productName, String fileName, BuildContext context) {
    PreviewType type = Provider.of<ProductDetailsController>(context, listen: false).getFileType(url);

    showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: (type == PreviewType.pdf) ?
        PdfPreview(url: url, fileName: productName) : (type == PreviewType.image) ?
        ImagePreview(url: url, fileName: productName) : (type == PreviewType.video) ?
        VideoPreview(url: url, fileName: productName) : (type == PreviewType.audio)  ?
        AudioPreview(url: url, fileName: productName) : (type == PreviewType.others) ?
        DownloadPreview(url: url, fileName: fileName) :
        const SizedBox(),
      );
    });
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({required this.child, required this.onTap, this.active = false});

  final Widget child;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: active ? AppPalette.brandGradient : null,
          color: active ? null : Theme.of(context).cardColor,
          border: Border.all(color: AppPalette.glassBorder(context)),
          boxShadow: AppPalette.softShadow(context),
        ),
        child: child,
      ),
    );
  }
}
