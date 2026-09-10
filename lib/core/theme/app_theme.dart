import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
      AppColors.lightTextTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        primary: AppColors.lightAccent,
        onPrimary: Colors.white,
        secondary: AppColors.lightAccentSubtle,
        onSecondary: AppColors.lightTextPrimary,
        error: AppColors.subtleDestructive,
        onError: Colors.white,
        outline: AppColors.lightBorder,
      ),
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 0.8,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.lightBorder, width: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        modalBackgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 12,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 16,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.lightAccent,
        inactiveTrackColor: AppColors.lightSurfaceSubtle,
        thumbColor: AppColors.lightAccent,
        overlayColor: AppColors.lightAccent.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
      AppColors.darkTextTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        primary: AppColors.darkAccent,
        onPrimary: Colors.black,
        secondary: AppColors.darkAccentSubtle,
        onSecondary: AppColors.darkTextPrimary,
        error: AppColors.subtleDestructive,
        onError: Colors.white,
        outline: AppColors.darkBorder,
      ),
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 0.8,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.darkBorder, width: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 12,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 16,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.darkAccent,
        inactiveTrackColor: AppColors.darkSurfaceSubtle,
        thumbColor: AppColors.darkAccent,
        overlayColor: AppColors.darkAccent.withValues(alpha: 0.16),
        trackHeight: 4,
      ),
    );
  }
}

extension ThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceElevatedColor =>
      isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
  Color get surfaceSubtleColor =>
      isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
  Color get textPrimaryColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondaryColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textTertiaryColor =>
      isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get dividerColor => isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get accentColor => isDark ? AppColors.darkAccent : AppColors.lightAccent;
}
