import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// FAQ card that expands to show its answer; highlighted while open.
class FaqExpansionTileWidget extends StatefulWidget {
  final int index;
  final SplashController faq;
  const FaqExpansionTileWidget({super.key, required this.index, required this.faq});

  @override
  State<FaqExpansionTileWidget> createState() => _FaqExpansionTileWidgetState();
}

class _FaqExpansionTileWidgetState extends State<FaqExpansionTileWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.faq.configModel!.faq![widget.index];
    final Color primary = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isExpanded ? primary : AppPalette.glassBorder(context), width: isExpanded ? 1.5 : 1),
        boxShadow: AppPalette.softShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(item.question ?? '', style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault, height: 1.5,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                )),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isExpanded ? primary.withValues(alpha: .14) : AppPalette.tint(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(isExpanded ? Icons.remove_rounded : Icons.add_rounded, size: 18,
                      color: isExpanded ? AppPalette.primaryDeep : Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ]),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(item.answer ?? '', style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall + 1, height: 1.8, color: Theme.of(context).hintColor,
                        )),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
