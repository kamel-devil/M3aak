import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppSupportButton extends StatefulWidget {
  final String? phoneNumber;
  final String? orderNumber;
  final String? orderDetails;
  final double? width;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  /// Square icon-only variant, used beside primary actions.
  final bool compact;

  const WhatsAppSupportButton({
    this.compact = false,
    super.key,
    this.phoneNumber,
    this.orderNumber,
    this.orderDetails,
    this.width,
    this.padding,
    this.onTap,
  });

  @override
  State<WhatsAppSupportButton> createState() => _WhatsAppSupportButtonState();
}

class _WhatsAppSupportButtonState extends State<WhatsAppSupportButton> {
  bool _isHovered = false;

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    // Remove any non-digit characters except +
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure phone number starts with +
    if (!cleanPhone.startsWith('+')) {
      if (!cleanPhone.startsWith('966') && !cleanPhone.startsWith('20')) {
        // If it doesn't have country code, assume Saudi Arabia (+966)
        if (cleanPhone.startsWith('05')) {
          cleanPhone = '+966${cleanPhone.substring(1)}';
        } else {
          cleanPhone = '+966$cleanPhone';
        }
      } else {
        cleanPhone = '+$cleanPhone';
      }
    }

    final whatsappUrl = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getTranslated('failed_to_open_whatsapp', context) ?? 'Failed to open WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(getTranslated('failed_to_open_whatsapp', context) ?? 'Failed to open WhatsApp')),
        );
      }
    }
  }

  String _buildMessage() {
    String message = getTranslated('hello_we_need_support', context) ?? 'السلام عليكم، أحتاج للدعم 👋\n';
    
    if (widget.orderNumber != null && widget.orderNumber!.isNotEmpty) {
      message += 'رقم الطلب: ${widget.orderNumber}\n';
    }
    
    if (widget.orderDetails != null && widget.orderDetails!.isNotEmpty) {
      message += 'تفاصيل الطلب:\n${widget.orderDetails}\n';
    }
    
    message += '\nشكراً لتواصلكم معنا! 🙏';
    return message;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.phoneNumber == null || widget.phoneNumber!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return Tooltip(
        message: getTranslated('تواصل مع الدعم', context) ?? 'WhatsApp',
        child: Material(
          color: const Color(0xFF25D366).withValues(alpha: .12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: const Color(0xFF25D366).withValues(alpha: .35)),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onTap: () {
              widget.onTap?.call();
              _launchWhatsApp(widget.phoneNumber!, _buildMessage());
            },
            child: SizedBox(
              width: 54,
              height: 54,
              child: Center(child: SizedBox(width: 26, height: 26,
                  child: Image.asset(Images.whatsapp, fit: BoxFit.contain))),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: widget.width ?? double.infinity,
        padding: widget.padding ?? const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [
                    const Color(0xFF25D366).withOpacity(0.15),
                    const Color(0xFF128C7E).withOpacity(0.1),
                  ]
                : [
                    const Color(0xFF25D366).withOpacity(0.08),
                    const Color(0xFF128C7E).withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF25D366).withOpacity(
              _isHovered ? 0.3 : 0.15,
            ),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF25D366).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onTap?.call();
              _launchWhatsApp(widget.phoneNumber!, _buildMessage());
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      Images.whatsapp,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    getTranslated('تواصل مع الدعم', context) ?? 'تواصل مع الدعم',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF128C7E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
