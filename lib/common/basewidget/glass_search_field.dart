import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// Rounded search field: leading search icon, and while typing a clear
/// button plus a gradient "search" button. Highlights its border on focus.
class GlassSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback? onClear;

  const GlassSearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  State<GlassSearchField> createState() => _GlassSearchFieldState();
}

class _GlassSearchFieldState extends State<GlassSearchField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _focus.hasFocus || widget.controller.text.isNotEmpty;
    final Color primary = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? primary : AppPalette.glassBorder(context), width: active ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: active ? primary.withValues(alpha: .14) : AppPalette.primaryDeep.withValues(alpha: .06),
            blurRadius: active ? 0 : 20,
            spreadRadius: active ? 4 : 0,
            offset: active ? Offset.zero : const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [
        Icon(Icons.search_rounded, color: primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            textInputAction: TextInputAction.search,
            onChanged: widget.onChanged,
            onSubmitted: (_) => widget.onSubmitted(),
            style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintText: widget.hintText,
              hintStyle: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
            ),
          ),
        ),
        if (widget.controller.text.isNotEmpty) ...[
          IconButton(
            tooltip: getTranslated('clear', context),
            onPressed: () {
              widget.controller.clear();
              widget.onClear?.call();
            },
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              fixedSize: const Size(32, 32),
              padding: EdgeInsets.zero,
              backgroundColor: AppPalette.tint(context),
            ),
            icon: Icon(Icons.close_rounded, size: 16, color: Theme.of(context).hintColor),
          ),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: getTranslated('search', context),
            child: InkWell(
              onTap: widget.onSubmitted,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}
