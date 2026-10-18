import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/notification/domain/models/notification_model.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/features/notification/controllers/notification_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/features/notification/widget/notification_dialog_widget.dart';
import 'package:provider/provider.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notificationItem;
  final int index;
  const NotificationItemWidget({super.key, required this.notificationItem, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, notificationController, _) {
        return InkWell(
            onTap:(){
              notificationController.seenNotification(notificationItem.id!);
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context, builder: (context) => NotificationDialogWidget(notificationModel: notificationItem),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              if(_willShowDate(index, notificationController.notificationModel?.notification)) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppPalette.glassBorder(context)),
                    ),
                    child: Text(
                      DateConverter.getRelativeDateStatus(notificationController.notificationModel?.notification?[index].createdAt ?? '', context),
                      style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: notificationItem.seen == null
                        ? Theme.of(context).primaryColor.withValues(alpha: .30)
                        : AppPalette.glassBorder(context),
                    width: 1.2,
                  ),
                  boxShadow: notificationItem.seen == null ? AppPalette.softShadow(context) : null,
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: AppPalette.tint(context),
                      child: CustomImageWidget(width: 56, height: 56, image: '${notificationItem.imageFullUrl?.path}', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Expanded(child: Text(
                          notificationItem.title ?? '',
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        if (notificationItem.seen == null)
                          Container(
                            width: 9, height: 9,
                            margin: const EdgeInsetsDirectional.only(start: 6),
                            decoration: const BoxDecoration(color: AppPalette.accent, shape: BoxShape.circle),
                          ),
                      ]),
                      const SizedBox(height: 3),
                      Text(notificationItem.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall + 1,
                          height: 1.45,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(DateConverter.getLocalTimeWithAMPM(notificationItem.createdAt ?? ''),
                        textDirection: TextDirection.ltr,
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall + 1,
                          color: Theme.of(context).primaryColor,
                        )),
                    ],
                  )),
                ]),
              ),
            ])),
        );
      }
    );
  }

  bool _willShowDate(int index, List<NotificationItem>? notificationList) {

    if (notificationList?.isEmpty ?? true) return false;
    if (index == 0) return true;


    final currentSupportTicket = notificationList?[index];
    final currentSupportTicketDate = DateTime.tryParse(currentSupportTicket?.createdAt ?? '');


    final previousSupportTicket = notificationList?[index - 1];
    final previousSupportTicketDate = DateTime.tryParse(previousSupportTicket?.createdAt ?? '');

    return currentSupportTicketDate?.day != previousSupportTicketDate?.day;
  }
}