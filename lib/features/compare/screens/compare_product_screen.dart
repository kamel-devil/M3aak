import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/compare/controllers/compare_controller.dart';
import 'package:kk_thotix_m3aak/features/search_product/widgets/partial_matched_widget.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/features/compare/widgets/remove_compare_list_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/compare/widgets/custom_top_sheet_widget.dart';
import 'package:provider/provider.dart';

class CompareProductScreen extends StatefulWidget {
  const CompareProductScreen({super.key});

  @override
  State<CompareProductScreen> createState() => _CompareProductScreenState();
}

class _CompareProductScreenState extends State<CompareProductScreen> {
  @override
  void initState() {
    Provider.of<CompareController>(context, listen: false).getCompareList();
    Provider.of<CompareController>(context, listen: false).getAttributeList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: '${getTranslated('compare_list', context)}'),
      body: Consumer<CompareController>(
        builder: (context, compareProvider,_) {
          return Column(children: [

            if(compareProvider.compareModel != null && compareProvider.compareModel!.compareLists != null &&
                compareProvider.compareModel!.compareLists!.isNotEmpty)
              InkWell(onTap: ()=> showModalBottomSheet(context: context, builder: (_)=> const RemoveFromCompareListBottomSheet()),
                child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const SizedBox(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppPalette.error.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
                      child: Text('${getTranslated('clear_all', context)}',
                        style: textBold.copyWith(color: AppPalette.error)))]))),

              Expanded(child: Padding(padding: const EdgeInsets.all(8.0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                      Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.start, children: [
                        const SizedBox(height: 260),
                        Container(width: 92,height: 48, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Flexible(child: Text('${getTranslated('price', context)}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.2, color: Theme.of(context).textTheme.bodyLarge?.color)))])),
                        Container(width: 92,height: 48,
                          decoration: BoxDecoration(color: Theme.of(context).cardColor),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Flexible(child: Text('${getTranslated('color', context)}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.2, color: Theme.of(context).textTheme.bodyLarge?.color)))])),


                        SizedBox(width: 92,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: compareProvider.attributeList?.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index){
                              return Container(height: 48,
                                decoration: BoxDecoration(color: index.isOdd? Theme.of(context).cardColor:
                                Theme.of(context).colorScheme.surface),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Flexible(child: Text('${compareProvider.attributeList?[index].name}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.2, color: Theme.of(context).textTheme.bodyLarge?.color)))]),
                              );
                            })),




                        Container(width: 92,height: 48,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Flexible(child: Text('${getTranslated('brand', context)}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.2, color: Theme.of(context).textTheme.bodyLarge?.color)))])),

                        Container(width: 92,height: 48,
                          decoration: BoxDecoration(color: Theme.of(context).cardColor),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Flexible(child: Text('${getTranslated('ratings', context)}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.2, color: Theme.of(context).textTheme.bodyLarge?.color)))])),

                      ],),
                      Expanded(
                        child: ListView(scrollDirection: Axis.horizontal,
                          children: [
                            (compareProvider.compareModel != null && compareProvider.compareModel!.compareLists != null && compareProvider.compareModel!.compareLists!.isNotEmpty)?
                            SizedBox(width: Dimensions.compareCardWidget, child: CompareCard(compareId: compareProvider.compareModel?.compareLists?[0].id, product: compareProvider.compareModel?.compareLists?[0].product)):
                            const SizedBox(width: Dimensions.compareCardWidget,child: CompareCard(product: null)),
                            (compareProvider.compareModel != null && compareProvider.compareModel!.compareLists != null && compareProvider.compareModel!.compareLists!.length > 1)?
                            SizedBox(width: Dimensions.compareCardWidget,child: CompareCard(compareId: compareProvider.compareModel?.compareLists?[1].id, product: compareProvider.compareModel?.compareLists?[1].product)):
                            const SizedBox(width: Dimensions.compareCardWidget,child: CompareCard(product: null)),
                            (compareProvider.compareModel != null && compareProvider.compareModel!.compareLists != null && compareProvider.compareModel!.compareLists!.length > 2)?
                            SizedBox(width: Dimensions.compareCardWidget,child: CompareCard(compareId: compareProvider.compareModel?.compareLists?[2].id, product: compareProvider.compareModel?.compareLists?[2].product)):
                            const SizedBox(width: Dimensions.compareCardWidget,child: CompareCard(product: null)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

class CompareCard extends StatelessWidget {
  final Product? product;
  final int? compareId;
  const CompareCard({super.key, required this.product, this.compareId});

  @override
  Widget build(BuildContext context) {

    return Consumer<CompareController>(
      builder: (context, compareProvider, _) {
        return Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if(product != null)
            InkWell(onTap: ()=> Provider.of<CompareController>(context, listen: false).addCompareList(product!.id!),
              child: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                Icon(Icons.clear, color: Theme.of(context).hintColor, size: 20,)]),),

            product != null?
            SizedBox(height: 65,
              child: Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall),
                child: Text(product?.name??'', maxLines: 2,overflow: TextOverflow.ellipsis, style: textRegular.copyWith(color: Theme.of(context).hintColor)),),
            ):const SizedBox(height: 85,),

            ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(22)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppPalette.glassBorder(context), width: 1.2),
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(22)),),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall,),

                    Stack(children: [
                        Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall),
                          child: Container(height: 155,
                            decoration: BoxDecoration(
                              color: AppPalette.tint(context),
                              borderRadius: const BorderRadius.all(Radius.circular(18))),
                            child: ClipRRect(borderRadius: const BorderRadius.all( Radius.circular(18)),
                              child: CustomImageWidget(image: '${product?.thumbnailFullUrl?.path}',
                                  height: 180,width: 200, placeholder: Images.emptyProduct)

                            ),
                          ),
                        ),
                        Positioned(right: 10,top: 0,
                            child: InkWell(onTap: () {
                              showCustomTopSheetWidget(context,widget : Column(children: [
                                  const SizedBox(height: 30),
                                  Row(children: [Expanded(child: Material(
                                    child: Container(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(color: Theme.of(context).canvasColor,
                                          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha:0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1),)]),
                                      child: SearchSuggestion(fromCompare: true,id: compareId))))],),
                                const SizedBox(height: Dimensions.paddingSizeDefault)]));
                            },
                              child: Card(elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: Container(decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30)),
                                    width: 30, height:30, child: Padding(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      child: Image.asset(Images.search,
                                          color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).hintColor : Theme.of(context).primaryColor.withValues(alpha:.25))))),
                            ))
                      ],
                    ),
                  Container(height: 48, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                          child: Text(product != null ? PriceConverter.convertPrice(context , product!.unitPrice) : '', style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                        ),
                      ],
                    ),
                  ),

                  Container(height: 48,padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                    color: Theme.of(context).cardColor),
                    child: product != null? product!.colors!.isNotEmpty?
                    Center(
                      child: ListView.builder(
                        itemCount: product!.colors!.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          String colorString = '0xff${product!.colors![index].code!.substring(1, 7)}';
                          return Center(
                            child: Container(decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                              child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Container(height: 15, width: 15,
                                  padding: const EdgeInsets.all( Dimensions.paddingSizeExtraSmall),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Color(int.parse(colorString)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ): Center(child: SizedBox(height: 48,width: 200,child: Center(child: Text('—', style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),)))):const SizedBox(),
                  ),

                  SizedBox(width: 200,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: compareProvider.attributeList?.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            List<List<String>> variation= [];
                            if(product != null && product!.choiceOptions != null && product!.choiceOptions!.isNotEmpty){
                              for(int i =0; i<compareProvider.attributeList!.length; i++){
                                for(int j =0 ; j< product!.choiceOptions!.length; j++){
                                  if(compareProvider.attributeList![i].name == product!.choiceOptions![j].title){
                                    variation.insert(i, product!.choiceOptions![j].options!);
                                  }else{
                                    variation.insert(i, ['No ${compareProvider.attributeList![i].name}']);
                                  }
                                }
                              }
                            }


                            return (product != null && product!.choiceOptions != null &&  product!.choiceOptions!.isNotEmpty)?
                            Container(height: 48,width: 200,
                              decoration: BoxDecoration(color: index.isOdd? Theme.of(context).cardColor:Theme.of(context).colorScheme.surface),
                              child: variation.isNotEmpty?
                              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                child: Center(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: variation[index].length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                      itemBuilder: (context, varIndex){
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                        child: Container(height: 48,
                                          decoration: BoxDecoration(color: index.isOdd? Theme.of(context).cardColor:Theme.of(context).colorScheme.surface),
                                          child: Text(variation[index][varIndex].trim(), style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                                        ),
                                      );

                                  }),
                                ),
                              ):const SizedBox(),
                            ): Center(child: SizedBox(height: 48,width: 200,child: Center(child: Text('No ${compareProvider.attributeList![index].name}', style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),))));
                          })),




                  Container(height: 48, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                    child:  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        child: Text(product?.brand?.name??'', style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),))])),

                  ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.paddingSizeSmall)),
                    child: Container(height: 48,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            const Icon(Icons.star_rounded, color: AppPalette.warning, size: 20),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(product != null ?double.parse(product!.rating != null && product!.rating!.isNotEmpty? product!.rating![0].average! : "0").toStringAsFixed(1):'',
                                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color,)),),



                            Text(product != null?'(${product!.reviewCount?? 0})' :'',
                                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                          ]),
                    ),
                  ),
                  ],
                ),
              ),
            ),

          ],),
        );
      }
    );
  }
}
