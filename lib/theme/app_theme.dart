import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors matching Figma
  static const Color primaryTeal = Color(0xFF00838F);
  static const Color primaryTealDark = Color(0xFF006972);
  static const Color accentMint = Color(0xFFE6F5F4);
  static const Color darkNavy = Color(0xFF0F2231);
  static const Color textMuted = Color(0xFF687D8D);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color pageBg = Color(0xFFF8FAFB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Status Badge Colors
  static const Color statusOnlineText = Color(0xFF0284C7);
  static const Color statusOnlineBg = Color(0xFFE0F2FE);

  static const Color statusOfflineText = Color(0xFFDC2626);
  static const Color statusOfflineBg = Color(0xFFFEE2E2);

  static const Color statusPendingText = Color(0xFFD97706);
  static const Color statusPendingBg = Color(0xFFFEF3C7);
}

class AppTheme {
  static const Color primary = AppColors.primaryTeal;
  static const Color primaryDark = AppColors.primaryTealDark;
  static const Color accentMint = AppColors.accentMint;
  static const Color textPrimary = AppColors.darkNavy;
  static const Color textSecondary = AppColors.textMuted;
  static const Color background = AppColors.pageBg;
  static const Color surface = AppColors.surfaceWhite;
  static const Color border = AppColors.borderGrey;
}

class AppStyles {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.borderGrey.withOpacity(0.7)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
      ),
    );
  }
}
