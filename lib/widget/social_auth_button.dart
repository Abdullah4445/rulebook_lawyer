import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';

/// Branded sign-in pills used on the login screen.
///
/// Each variant respects the provider's visual identity instead of
/// inheriting the generic bordered-button look:
///
///   • Google    — white surface, multi-colour Google "G" mark,
///                 navy "Continue with Google" label
///   • Facebook  — Facebook blue (#1877F2) surface, white "f" mark,
///                 white "Continue with Facebook" label
///   • Apple     — black surface, white apple mark,
///                 white "Continue with Apple" label
///
/// All three share a single layout primitive so spacing, height and
/// border-radius stay perfectly consistent across the row.
class SocialAuthButton extends StatelessWidget {
  final SocialAuthVariant variant;
  final VoidCallback onTap;
  final String? customLabel;
  final bool busy;

  const SocialAuthButton({
    super.key,
    required this.variant,
    required this.onTap,
    this.customLabel,
    this.busy = false,
  });

  const SocialAuthButton.google({Key? key, required VoidCallback onTap, bool busy = false})
      : this(key: key, variant: SocialAuthVariant.google, onTap: onTap, busy: busy);

  const SocialAuthButton.facebook({Key? key, required VoidCallback onTap, bool busy = false})
      : this(key: key, variant: SocialAuthVariant.facebook, onTap: onTap, busy: busy);

  const SocialAuthButton.apple({Key? key, required VoidCallback onTap, bool busy = false})
      : this(key: key, variant: SocialAuthVariant.apple, onTap: onTap, busy: busy);

  @override
  Widget build(BuildContext context) {
    final spec = _spec(variant);
    final label = customLabel ?? spec.label;

    return PressScale(
      scale: 0.97,
      onTap: busy ? () {} : onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: spec.bg,
          borderRadius: BorderRadius.circular(14),
          border: spec.border == null
              ? null
              : Border.all(color: spec.border!, width: 1),
          boxShadow: [
            BoxShadow(
              color: spec.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            spec.iconBuilder(),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: spec.textColor,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            if (busy) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(spec.textColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _Spec _spec(SocialAuthVariant v) {
    switch (v) {
      case SocialAuthVariant.google:
        return _Spec(
          bg: Colors.white,
          textColor: AppColors.brandNavy,
          border: const Color(0xFFE2E5EB),
          shadow: Colors.black.withValues(alpha: 0.06),
          label: 'Continue with Google',
          iconBuilder: () => Image.asset(
            'assets/icons/ic_google.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
        );
      case SocialAuthVariant.facebook:
        return _Spec(
          bg: const Color(0xFF1877F2),
          textColor: Colors.white,
          border: null,
          shadow: const Color(0xFF1877F2).withValues(alpha: 0.30),
          label: 'Continue with Facebook',
          iconBuilder: () => Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'f',
              style: TextStyle(
                color: Color(0xFF1877F2),
                fontWeight: FontWeight.w900,
                fontSize: 16,
                height: 1.0,
              ),
            ),
          ),
        );
      case SocialAuthVariant.apple:
        return _Spec(
          bg: Colors.black,
          textColor: Colors.white,
          border: null,
          shadow: Colors.black.withValues(alpha: 0.25),
          label: 'Continue with Apple',
          iconBuilder: () => const Icon(Icons.apple, color: Colors.white, size: 24),
        );
    }
  }
}

enum SocialAuthVariant { google, facebook, apple }

class _Spec {
  final Color bg;
  final Color textColor;
  final Color? border;
  final Color shadow;
  final String label;
  final Widget Function() iconBuilder;

  _Spec({
    required this.bg,
    required this.textColor,
    required this.border,
    required this.shadow,
    required this.label,
    required this.iconBuilder,
  });
}
