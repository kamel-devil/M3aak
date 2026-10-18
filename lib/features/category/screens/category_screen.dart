import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/product_widget.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/category/controllers/category_controller.dart';
import 'package:kk_thotix_m3aak/features/category/domain/models/category_model.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.showBackButton});
  final bool showBackButton;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();

    final CategoryController categoryController =
        Provider.of<CategoryController>(context, listen: false);
    if (categoryController.categoryList.isNotEmpty) {
      Provider.of<ProductController>(context, listen: false)
          .initBrandOrCategoryProductList(
        isBrand: false,
        id: categoryController.categoryList[0].id,
        offset: 1,
        isUpdate: false,
      );

      categoryController.onChangeSelectedIndex(0, isUpdate: false);
    }
  }

  void _select(CategoryController controller, int index) {
    controller.onChangeSelectedIndex(index);
    Provider.of<ProductController>(context, listen: false)
        .initBrandOrCategoryProductList(
      isBrand: false,
      id: controller.categoryList[index].id,
      offset: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inside the dashboard the floating nav bar overlaps the bottom.
    final double bottomInset = widget.showBackButton ? 16 : 104;

    return Scaffold(
      appBar: CustomAppBar(
          title: getTranslated('CATEGORY', context),
          isBackButtonExist: widget.showBackButton),
      body: Consumer<CategoryController>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categoryList.isEmpty) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)));
          }

          final int selected = categoryProvider.categorySelectedIndex ?? 0;
          final CategoryModel category = categoryProvider.categoryList[selected];

          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Category rail
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12, 10, 0, bottomInset),
              child: GlassContainer(
                blur: false,
                width: 92,
                radius: 28,
                padding: const EdgeInsets.all(6),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: categoryProvider.categoryList.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final CategoryModel item = categoryProvider.categoryList[index];
                    return _RailItem(
                      title: item.name ?? '',
                      icon: item.imageFullUrl?.path,
                      isSelected: selected == index,
                      onTap: () => _select(categoryProvider, index),
                    );
                  },
                ),
              ),
            ),

            // Selected category
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                ),
                child: _CategoryPane(
                  key: ValueKey(category.id),
                  category: category,
                  bottomInset: bottomInset,
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: .94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppPalette.brandGradient : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppPalette.primary.withValues(alpha: .35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isSelected
                  ? Colors.white
                  : (AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white.withValues(alpha: .9)),
              border: Border.all(
                  color: isSelected ? Colors.white : AppPalette.tint(context), width: 1.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CustomImageWidget(fit: BoxFit.cover, image: '$icon'),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: (isSelected ? textBold : textMedium).copyWith(
              fontSize: Dimensions.fontSizeSmall,
              height: 1.2,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            child: Text(title,
                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          ),
        ]),
      ),
    );
  }
}

class _CategoryPane extends StatelessWidget {
  const _CategoryPane({super.key, required this.category, required this.bottomInset});

  final CategoryModel category;
  final double bottomInset;

  void _openAll() => RouterHelper.getBrandCategoryRoute(
        isBrand: false,
        id: category.id,
        name: category.name,
        categoryModel: category,
        isAllProduct: true,
      );

  @override
  Widget build(BuildContext context) {
    final List<SubCategory> subs = category.subCategories ?? [];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(12, 10, 14, bottomInset),
      children: [
        _CategoryHero(category: category, onViewAll: _openAll),
        const SizedBox(height: 14),
        if (subs.isEmpty)
          _CategoryProductsPreview(onViewAll: _openAll),
        for (int i = 0; i < subs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FadeSlideIn(
              index: i,
              offset: const Offset(0, 16),
              child: _SubCategoryCard(category: category, subCategory: subs[i], index: i),
            ),
          ),
      ],
    );
  }
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({required this.category, required this.onViewAll});

  final CategoryModel category;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final int count = category.totalProductCount ?? 0;

    return PressableScale(
      scale: .98,
      onTap: onViewAll,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppPalette.brandGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppPalette.primaryDeep.withValues(alpha: .28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(children: [
            PositionedDirectional(
              end: -40,
              bottom: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      category.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                          color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge, height: 1.25),
                    ),
                    if (count > 0) ...[
                      const SizedBox(height: 2),
                      Text('$count ${getTranslated('products', context)}',
                          style: textRegular.copyWith(
                              color: Colors.white.withValues(alpha: .85),
                              fontSize: Dimensions.fontSizeSmall)),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Flexible(
                          child: Text(getTranslated('all_products', context) ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textBold.copyWith(
                                  color: AppPalette.primaryDeep, fontSize: Dimensions.fontSizeSmall)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 15, color: AppPalette.primaryDeep),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 74,
                  height: 74,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withValues(alpha: .5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomImageWidget(image: '${category.imageFullUrl?.path}', fit: BoxFit.cover),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Sub-category card. Cards with sub-sub-categories expand to reveal chips.
class _SubCategoryCard extends StatefulWidget {
  const _SubCategoryCard({required this.category, required this.subCategory, required this.index});

  final CategoryModel category;
  final SubCategory subCategory;
  final int index;

  @override
  State<_SubCategoryCard> createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<_SubCategoryCard> {
  bool _expanded = false;

  static const List<Color> _accents = [
    AppPalette.primary,
    AppPalette.secondary,
    AppPalette.accent,
    AppPalette.warning,
    Color(0xFF8B6CF0),
  ];

  bool get _hasChildren => widget.subCategory.subSubCategories?.isNotEmpty ?? false;

  void _onTap() {
    if (_hasChildren) {
      setState(() => _expanded = !_expanded);
      return;
    }
    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: widget.subCategory.id,
      name: widget.category.name,
      categoryModel: widget.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SubCategory sub = widget.subCategory;
    final Color accent = _accents[widget.index % _accents.length];
    final String name = sub.name ?? '';
    final int count = sub.totalProductCount ?? 0;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return GlassContainer(
      blur: false,
      radius: 22,
      padding: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent.withValues(alpha: .25), accent.withValues(alpha: .10)],
                  ),
                ),
                child: Text(
                  name.isNotEmpty ? name.characters.first : '•',
                  style: textBold.copyWith(color: accent, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  if (count > 0)
                    Text('$count ${getTranslated('products', context)}',
                        style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                ]),
              ),
              AnimatedRotation(
                turns: _hasChildren && _expanded ? (rtl ? -.25 : .25) : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppPalette.tint(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                      size: 20, color: Theme.of(context).primaryColor),
                ),
              ),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: _hasChildren && _expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      _Chip(
                        label: getTranslated('all_products', context) ?? '',
                        highlighted: true,
                        onTap: () => RouterHelper.getBrandCategoryRoute(
                          action: RouteAction.push,
                          isBrand: false,
                          id: sub.id,
                          name: sub.name,
                          subCategory: sub,
                          isAllProduct: true,
                        ),
                      ),
                      for (final subSub in sub.subSubCategories!)
                        _Chip(
                          label: subSub.name ?? '',
                          onTap: () => RouterHelper.getBrandCategoryRoute(
                            action: RouteAction.push,
                            isBrand: false,
                            id: subSub.id,
                            name: sub.name,
                            subCategory: sub,
                          ),
                        ),
                    ]),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap, this.highlighted = false});

  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: highlighted ? AppPalette.brandGradient : null,
          color: highlighted ? null : AppPalette.tint(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: highlighted ? Colors.white : Theme.of(context).primaryColor,
            )),
      ),
    );
  }
}

/// Shown for categories without sub-categories: a few of the category's
/// products plus a "view all" button.
class _CategoryProductsPreview extends StatelessWidget {
  const _CategoryProductsPreview({required this.onViewAll});

  final VoidCallback onViewAll;
  static const int _previewCount = 6;

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (_, controller) => controller.brandOrCategoryProductList,
      builder: (context, model, _) {
        // Still loading.
        if (model == null) {
          return MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: 4,
            itemBuilder: (_, __) => const _ProductPlaceholder(),
          );
        }

        final List<Product> products = model.products ?? [];
        if (products.isEmpty) {
          return GlassContainer(
            blur: false,
            radius: 22,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(children: [
              Icon(Icons.medication_outlined, size: 40, color: Theme.of(context).hintColor),
              const SizedBox(height: 8),
              Text(getTranslated('no_product_found', context) ?? '',
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(color: Theme.of(context).hintColor)),
            ]),
          );
        }

        final List<Product> preview = products.take(_previewCount).toList();
        return Column(children: [
          MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: preview.length,
            itemBuilder: (context, index) => FadeSlideIn(
              index: index,
              offset: const Offset(0, 18),
              child: ProductWidget(productModel: preview[index], margin: 4),
            ),
          ),
          const SizedBox(height: 14),
          PressableScale(
            onTap: onViewAll,
            scale: .97,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: AppPalette.brandGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.primary.withValues(alpha: .30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(getTranslated('view_all_products', context) ?? '',
                    style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  const _ProductPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GlassContainer(
        blur: false,
        radius: 22,
        showShadow: false,
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppPalette.tint(context),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 10, width: double.infinity, color: AppPalette.tint(context)),
          const SizedBox(height: 6),
          Container(height: 10, width: 60, color: AppPalette.tint(context)),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
