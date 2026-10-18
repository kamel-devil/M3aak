import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool showResetIcon;
  final Widget? reset;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.showActionButton = true,
    this.fontSize,
    this.showResetIcon = false,
    this.reset,
    this.showLogo = false
  });

  @override
  Widget build(BuildContext context) {
    final Color ink = Theme.of(context).textTheme.bodyLarge!.color!;
    final bool dark = AppPalette.isDark(context);

    return AppBar(
      actions: showResetIcon ? [reset!] : [],
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: ink),
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? [AppPalette.darkBgTop.withValues(alpha: .85), AppPalette.darkBgTop.withValues(alpha: .6)]
                    : [AppPalette.lightBgTop.withValues(alpha: .92), AppPalette.lightBgMid.withValues(alpha: .78)],
              ),
              border: Border(
                  bottom: BorderSide(color: AppPalette.glassBorder(context))),
            ),
          ),
        ),
      ),
      title: Text(title ?? '',
          style: textBold.copyWith(
              fontSize: fontSize ?? Dimensions.fontSizeExtraLarge, color: ink),
          maxLines: 1,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis),
      centerTitle: centerTitle,
      excludeHeaderSemantics: true,
      titleSpacing: 0,
      clipBehavior: Clip.none,
      leadingWidth: isBackButtonExist ? 64 : 120,
      leading: isBackButtonExist
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 14),
              child: Center(
                child: PressableScale(
                  onTap: () => onBackPressed != null
                      ? onBackPressed!()
                      : Navigator.pop(context),
                  child: GlassContainer(
                    width: 44,
                    height: 44,
                    radius: 15,
                    blur: false,
                    showShadow: true,
                    color: dark ? AppPalette.darkGlass : Colors.white.withValues(alpha: .92),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 17, color: ink),
                  ),
                ),
              ),
            )
          : showLogo
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeDefault),
                  child:
                      SizedBox(child: Image.asset(Images.logoWithNameImage)))
              : const SizedBox(),
    );
  }

  @override
  Size get preferredSize => Size(MediaQuery.of(Get.context!).size.width, 72);
}
