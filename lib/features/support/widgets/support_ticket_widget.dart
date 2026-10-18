import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/support/controllers/support_ticket_controller.dart';
import 'package:kk_thotix_m3aak/features/support/domain/models/support_ticket_model.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/shipping_details_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

/// Support ticket card: type icon, subject, status pill, priority and time.
class SupportTicketWidget extends StatelessWidget {
  final SupportTicketModel supportTicketModel;
  final int index;
  const SupportTicketWidget({super.key, required this.supportTicketModel, required this.index});

  static (IconData, Color) _typeStyle(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'website problem':
        return (Icons.bug_report_outlined, AppPalette.secondary);
      case 'complaint':
        return (Icons.report_gmailerrorred_rounded, AppPalette.error);
      case 'partner request':
        return (Icons.handshake_outlined, AppPalette.warning);
      default:
        return (Icons.help_outline_rounded, AppPalette.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportTicketController>(
      builder: (context, supportTicketController, _) {
        final (IconData typeIcon, Color typeColor) = _typeStyle(supportTicketModel.type);
        final String status = supportTicketModel.status ?? '';
        final Color statusColor = status == 'open'
            ? AppPalette.success
            : status == 'pending' ? const Color(0xFFA15C00) : Theme.of(context).hintColor;
        final String priority = supportTicketModel.priority ?? '';
        final Color priorityColor = priority.toLowerCase() == 'urgent'
            ? AppPalette.error
            : priority.toLowerCase() == 'high' ? const Color(0xFFA15C00) : Theme.of(context).hintColor;
        final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_willShowDate(index, supportTicketController.supportTicketList))
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Text(
                DateConverter.getRelativeDateStatus(supportTicketModel.createdAt ?? '', context),
                style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Slidable(
                key: ValueKey(supportTicketModel.id),
                endActionPane: status == 'close' ? null : ActionPane(
                  extentRatio: .25,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => Provider.of<SupportTicketController>(context, listen: false).closeSupportTicket(supportTicketModel.id),
                      backgroundColor: AppPalette.error.withValues(alpha: .1),
                      foregroundColor: AppPalette.error,
                      icon: Icons.close_rounded,
                      label: getTranslated('close', context),
                    ),
                  ],
                ),
                child: PressableScale(
                  onTap: () => RouterHelper.getSupportConversationRoute(
                    action: RouteAction.push,
                    supportTicketModel: supportTicketModel,
                  ),
                  child: GlassContainer(
                    blur: false,
                    radius: 22,
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: typeColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                          child: Icon(typeIcon, size: 19, color: typeColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(supportTicketModel.subject ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor)),
                          Text(getTranslated(_toSnakeCase(supportTicketModel.type ?? ''), context) ?? supportTicketModel.type ?? '',
                              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                        ])),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status == 'pending'
                                ? getTranslated('pending', context)!
                                : status == 'open' ? getTranslated('open', context)! : getTranslated('closed', context)!,
                            style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1, color: statusColor),
                          ),
                        ),
                      ]),
                      if ((supportTicketModel.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(supportTicketModel.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall + 1, height: 1.5, color: textColor?.withValues(alpha: .75))),
                      ],
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.flag_outlined, size: 14, color: priorityColor),
                        const SizedBox(width: 3),
                        Text(getTranslated(_toSnakeCase(priority), context) ?? (priority.isEmpty ? '' : priority.capitalize()),
                            style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1, color: priorityColor)),
                        const SizedBox(width: 10),
                        Icon(Icons.schedule_rounded, size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 3),
                        Text(DateConverter.getLocalTimeWithAMPM(supportTicketModel.createdAt ?? ''),
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1, color: Theme.of(context).hintColor)),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  String _toSnakeCase(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  bool _willShowDate(int index, List<SupportTicketModel>? supportTicketList) {
    if (supportTicketList?.isEmpty ?? true) return false;
    if (index == 0) return true;
    final currentDate = DateTime.tryParse(supportTicketList?[index].createdAt ?? '');
    final previousDate = DateTime.tryParse(supportTicketList?[index - 1].createdAt ?? '');
    return currentDate?.day != previousDate?.day;
  }
}
