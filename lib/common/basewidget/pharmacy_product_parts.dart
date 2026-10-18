import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/favourite_button_widget.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Price / discount helpers shared by every product card.
class ProductPricing {
  ProductPricing._();

  static bool _clearance(Product p) => (p.clearanceSale?.discountAmount ?? 0) > 0;

  static bool hasDiscount(Product p) =>
      (p.discount != null && p.discount! > 0) || _clearance(p);

  static bool inStock(Product p) =>
      (p.currentStock ?? 0) > 0 || p.productType != 'physical';

  static double rating(Product p) => (p.rating?.isNotEmpty ?? false)
      ? double.tryParse('${p.rating![0].average}') ?? 0
      : 0;

  static String finalPrice(BuildContext context, Product p) =>
      PriceConverter.convertPrice(
        context,
        p.unitPrice,
        discountType: _clearance(p) ? p.clearanceSale?.discountType : p.discountType,
        discount: _clearance(p) ? p.clearanceSale?.discountAmount : p.discount,
      );

  static String originalPrice(BuildContext context, Product p) =>
      PriceConverter.convertPrice(context, p.unitPrice);

  static String discountLabel(BuildContext context, Product p) => _clearance(p)
      ? PriceConverter.percentageCalculation(context, p.unitPrice,
          p.clearanceSale?.discountAmount, p.clearanceSale?.discountType)
      : PriceConverter.percentageCalculation(
          context, p.unitPrice, p.discount, p.discountType);

  static void openDetails(Product p) => RouterHelper.getProductDetailsRoute(
      action: RouteAction.push, productId: p.id, slug: p.slug);
}

/// Coral pill showing the discount ("-10%").
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.label, this.small = false});

  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 9, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        gradient: AppPalette.offerGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: AppPalette.accent.withValues(alpha: .30),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(label,
            style: textBold.copyWith(
                color: Colors.white,
                fontSize: small ? Dimensions.fontSizeExtraSmall : Dimensions.fontSizeSmall)),
      ),
    );
  }
}

/// Final price with the struck-through original underneath when discounted.
class ProductPriceText extends StatelessWidget {
  const ProductPriceText({super.key, required this.product, this.large = false});

  final Product product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final bool discounted = ProductPricing.hasDiscount(product);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            ProductPricing.finalPrice(context, product),
            maxLines: 1,
            style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: large ? Dimensions.fontSizeExtraLarge : Dimensions.fontSizeLarge,
            ),
          ),
        ),
        if (discounted)
          Text(
            ProductPricing.originalPrice(context, product),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textRegular.copyWith(
              color: Theme.of(context).hintColor,
              decoration: TextDecoration.lineThrough,
              decorationColor: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
      ],
    );
  }
}

/// Gradient "+" that adds one unit to the cart and morphs into a check.
/// Products with options open the details page instead.
class QuickAddCartButton extends StatefulWidget {
  const QuickAddCartButton({super.key, required this.product, this.size = 38});

  final Product product;
  final double size;

  @override
  State<QuickAddCartButton> createState() => _QuickAddCartButtonState();
}

class _QuickAddCartButtonState extends State<QuickAddCartButton> {
  bool _added = false;
  bool _busy = false;

  Future<void> _add() async {
    final Product p = widget.product;
    final bool hasOptions = (p.choiceOptions?.isNotEmpty ?? false) ||
        (p.colors?.isNotEmpty ?? false) ||
        (p.variation?.isNotEmpty ?? false) ||
        (p.digitalVariation?.isNotEmpty ?? false);

    if (hasOptions) {
      ProductPricing.openDetails(p);
      return;
    }
    if (!ProductPricing.inStock(p)) {
      showCustomSnackBar(getTranslated('out_of_stock', context), context);
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);

    final cartController = Provider.of<CartController>(context, listen: false);
    final apiResponse = await cartController.cartServiceInterface!.addToCartListData(
      CartModelBody(productId: p.id, variant: '', color: '', quantity: 1),
      p.choiceOptions ?? [],
      const [],
      0,
      null,
      null,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final bool ok = apiResponse.response!.data['status'] != 0;
      showCustomSnackBar(apiResponse.response!.data['message'], context,
          isError: !ok, isToaster: true);
      cartController.getCartData(context);
      if (ok) {
        setState(() => _added = true);
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _added = false);
        });
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return PressableScale(
      onTap: _add,
      scale: .85,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(s * .38),
          gradient: _added
              ? const LinearGradient(colors: [AppPalette.success, Color(0xFF17A06A)])
              : AppPalette.brandGradient,
          boxShadow: [
            BoxShadow(
              color: (_added ? AppPalette.success : AppPalette.primary)
                  .withValues(alpha: .35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: RotationTransition(
                turns: Tween<double>(begin: -.25, end: 0).animate(anim), child: child),
          ),
          child: _busy
              ? SizedBox(
                  key: const ValueKey('busy'),
                  width: s * .42,
                  height: s * .42,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(_added ? Icons.check_rounded : Icons.add_rounded,
                  key: ValueKey(_added), color: Colors.white, size: s * .52),
        ),
      ),
    );
  }
}

/// Soft tinted square that frames a product packshot.
class ProductImageTile extends StatelessWidget {
  const ProductImageTile({
    super.key,
    required this.product,
    required this.size,
    this.radius = 18,
  });

  final Product product;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool inStock = ProductPricing.inStock(product);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: AppPalette.isDark(context)
            ? AppPalette.darkTint
            : Colors.white,
        border: Border.all(color: AppPalette.tint(context), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Stack(fit: StackFit.expand, children: [
          Padding(
            padding: EdgeInsets.all(size * .06),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius * .6),
              child: CustomImageWidget(
                image: '${product.thumbnailFullUrl?.path}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (!inStock)
            Container(
              color: Colors.white.withValues(alpha: .55),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPalette.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(getTranslated('out_of_stock', context) ?? '',
                    style: textBold.copyWith(
                        color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Compact horizontal product card for carousels and lists.
class ProductRowTile extends StatelessWidget {
  const ProductRowTile({super.key, required this.product, this.imageSize = 84});

  final Product product;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final double rating = ProductPricing.rating(product);
    return PressableScale(
      scale: .98,
      haptic: false,
      onTap: () => ProductPricing.openDetails(product),
      child: GlassContainer(
        blur: false,
        radius: 22,
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            ProductImageTile(product: product, size: imageSize, radius: 16),
            if (ProductPricing.hasDiscount(product))
              PositionedDirectional(
                top: -4,
                start: -4,
                child: DiscountBadge(
                    label: ProductPricing.discountLabel(context, product), small: true),
              ),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    height: 1.25,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (rating > 0) ...[
                  const SizedBox(height: 3),
                  RatingPill(rating: rating),
                ],
                const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: ProductPriceText(product: product)),
                  QuickAddCartButton(product: product, size: 34),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating, this.count});

  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, color: AppPalette.warning, size: 15),
      const SizedBox(width: 2),
      Text(rating.toStringAsFixed(1),
          style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color)),
      if (count != null)
        Text(' ($count)',
            style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
    ]);
  }
}

/// Small frosted heart button.
class GlassFavouriteButton extends StatelessWidget {
  const GlassFavouriteButton({super.key, required this.productId});

  final int? productId;

  @override
  Widget build(BuildContext context) {
    return FavouriteButtonWidget(
      backgroundColor: Theme.of(context).cardColor,
      productId: productId,
    );
  }
}
