import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_asset_image_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/notification/controllers/notification_controller.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Settings-style row: tinted icon tile, title, and a badge or chevron.
class MenuButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final bool isNotification;
  final bool isProfile;
  final Function? onTap;
  final Color color;
  final Widget? trailing;
  /// Optional icon used instead of [image].
  final IconData? icon;
  const MenuButtonWidget({super.key, required this.image, required this.title, this.navigateTo,
    this.isNotification = false, this.isProfile = false, this.onTap,
    this.color = AppPalette.primary, this.trailing, this.icon});

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool loggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();

    Widget? badge;
    if (isNotification && loggedIn) {
      badge = Consumer<NotificationController>(builder: (context, controller, _) {
        final int count = controller.notificationModel?.newNotificationItem ?? 0;
        return count > 0 ? _Badge(text: '$count') : const SizedBox.shrink();
      });
    } else if (isProfile) {
      badge = Consumer<ProfileController>(builder: (context, profile, _) {
        final int count = profile.userInfoModel?.referCount ?? 0;
        return count > 0 ? _Badge(text: '$count') : const SizedBox.shrink();
      });
    }

    return InkWell(
      onTap: onTap != null ? () => onTap!() : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(icon != null ? 0 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: .20), color.withValues(alpha: .08)],
              ),
            ),
            child: icon != null
                ? Icon(icon, size: 20, color: color)
                : CustomAssetImageWidget(image, width: 20, height: 20, fit: BoxFit.contain, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
          if (badge != null) ...[badge, const SizedBox(width: 6)],
          trailing ??
              Icon(rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  size: 20, color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)),
    );
  }
}
