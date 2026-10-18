import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class ProductSpecificationWidget extends StatelessWidget {
  final String productSpecification;

  const ProductSpecificationWidget({super.key, required this.productSpecification});

  @override
  Widget build(BuildContext context) {

    return Column(crossAxisAlignment : CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              Container(
                height: (productSpecification.isNotEmpty && productSpecification.length > 400) ? 150 : null,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: HtmlWidget(
                    productSpecification,
                    onTapUrl: (String url) {
                      return launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                    },
                    textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault, height: 1.7),
                  ),
                ),
              ),

              if((productSpecification.isNotEmpty && productSpecification.length > 400))
                Positioned(left: 0, right: 0, bottom: 0, height: 48, child: IgnorePointer(
                  child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Theme.of(context).cardColor.withValues(alpha: 0), Theme.of(context).cardColor],
                  ))),
                )),
            ]),

            if((productSpecification.isNotEmpty && productSpecification.length > 400))
              TextButton(
                onPressed: () => RouterHelper.getSpecificationRoute(productSpecification.toString()),
                style: TextButton.styleFrom(minimumSize: const Size(44, 40), padding: const EdgeInsets.symmetric(horizontal: 4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(getTranslated('read_more', context) ?? '', style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall + 1,
                    color: Provider.of<ThemeController>(context, listen: false).darkTheme ? Colors.white : AppPalette.primaryDeep,
                  )),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                      color: Provider.of<ThemeController>(context, listen: false).darkTheme ? Colors.white : AppPalette.primaryDeep),
                ]),
              ),


          ]),
        )

      ],
    );
  }
}
