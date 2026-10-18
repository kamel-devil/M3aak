import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';

class SupportTicketTypeWidget extends StatefulWidget {
  const SupportTicketTypeWidget({super.key});

  @override
  State<SupportTicketTypeWidget> createState() => _SupportTicketTypeWidgetState();
}

class _SupportTicketTypeWidgetState extends State<SupportTicketTypeWidget> {
  List<TicketModel> issueTypeList = [
    TicketModel(Images.websiteProblem, 'website_problem'),
    TicketModel(Images.partnerRequest, 'partner_request'),
    TicketModel(Images.complaint, 'complaint'),
    TicketModel(Images.infoQuery, 'info_inquiry'),
  ];

  @override
  Widget build(BuildContext context) {

    return Container(height: MediaQuery.of(context).size.height/2,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,
          Dimensions.paddingSizeLarge, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha:.45),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)))
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            child: Text(getTranslated('select_your_category', context)!,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),),

          Expanded(child: GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
              itemCount: issueTypeList.length,
              itemBuilder: (context, index) {
                return InkWell(onTap: () {
                  RouterHelper.getAddTicketRoute(
                    action: RouteAction.push,
                    ticketModel: issueTypeList[index],
                    categoryIndex: index,
                  );
                  Navigator.of(context).pop();
                }, child: TypeButton(icon: issueTypeList[index].icon, title: issueTypeList[index].title));
              }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2/1.5)),
          )
        ],),
      ),
    );
  }
}

class TicketModel {
  final String icon;
  final String title;

  TicketModel(this.icon, this.title);

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      json['icon'] as String,
      json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
    };
  }
}


class TypeButton extends StatelessWidget {
  final String? icon;
  final String? title;
  const TypeButton({super.key, this.icon, this.title});

  static (IconData, Color) _style(String? title) {
    switch (title) {
      case 'website_problem': return (Icons.bug_report_outlined, AppPalette.secondary);
      case 'partner_request': return (Icons.handshake_outlined, AppPalette.warning);
      case 'complaint': return (Icons.report_gmailerrorred_rounded, AppPalette.error);
      default: return (Icons.help_outline_rounded, AppPalette.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (IconData iconData, Color color) = _style(title);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.tint(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.glassBorder(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)),
          child: Icon(iconData, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        Text(getTranslated(title, context) ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ]),
    );
  }
}
