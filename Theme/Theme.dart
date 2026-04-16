// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFF66FFF9);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF42A5F5);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242);
  static const Color divider = Color(0xFFE0E0E0);
  
  // DMS Specific Colors
  static const Color salesPrimary = Color(0xFF1565C0);
  static const Color inventoryPrimary = Color(0xFF388E3C);
  static const Color orderPrimary = Color(0xFFE65100);
  static const Color customerPrimary = Color(0xFF7B1FA2);
  static const Color reportPrimary = Color(0xFFD32F2F);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF757575);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// lib/core/theme/text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class TextStyles {
  // Font Family
  static const String fontFamily = 'Roboto';
  
  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  // Custom DMS Styles
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    fontFamily: fontFamily,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.white,
    fontFamily: fontFamily,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle statusActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
    fontFamily: fontFamily,
  );
  
  static const TextStyle statusInactive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
    fontFamily: fontFamily,
  );
  
  static const TextStyle statusPending = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
    fontFamily: fontFamily,
  );
  
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    fontFamily: fontFamily,
  );
  
  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    fontFamily: fontFamily,
  );
}

// lib/core/theme/theme_data.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        titleTextStyle: TextStyles.appBarTitle,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        shadowColor: AppColors.cardShadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: TextStyles.buttonText,
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyles.buttonText.copyWith(color: AppColors.primary),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyles.buttonText.copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: TextStyles.labelMedium,
        hintStyle: TextStyles.hintText,
        errorStyle: TextStyles.errorText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppColors.white,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyles.bodyLarge,
        subtitleTextStyle: TextStyles.bodyMedium,
        iconColor: AppColors.textSecondary,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyles.labelSmall,
        unselectedLabelStyle: TextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyles.displayLarge,
        displayMedium: TextStyles.displayMedium,
        displaySmall: TextStyles.displaySmall,
        headlineLarge: TextStyles.headlineLarge,
        headlineMedium: TextStyles.headlineMedium,
        headlineSmall: TextStyles.headlineSmall,
        titleLarge: TextStyles.titleLarge,
        titleMedium: TextStyles.titleMedium,
        titleSmall: TextStyles.titleSmall,
        bodyLarge: TextStyles.bodyLarge,
        bodyMedium: TextStyles.bodyMedium,
        bodySmall: TextStyles.bodySmall,
        labelLarge: TextStyles.labelLarge,
        labelMedium: TextStyles.labelMedium,
        labelSmall: TextStyles.labelSmall,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.greyLight,
        circularTrackColor: AppColors.greyLight,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.greyLight;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.borderMedium, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderMedium;
        }),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.errorLight,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.textLight,
        onBackground: AppColors.textLight,
        onError: AppColors.black,
      ),
      
      // App Bar Theme cho Dark Mode
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textLight,
        elevation: 2,
        shadowColor: AppColors.black,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          fontFamily: TextStyles.fontFamily,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      
      // Các theme khác tương tự như lightTheme nhưng với màu dark
      textTheme: TextTheme(
        displayLarge: TextStyles.displayLarge.copyWith(color: AppColors.textLight),
        displayMedium: TextStyles.displayMedium.copyWith(color: AppColors.textLight),
        displaySmall: TextStyles.displaySmall.copyWith(color: AppColors.textLight),
        headlineLarge: TextStyles.headlineLarge.copyWith(color: AppColors.textLight),
        headlineMedium: TextStyles.headlineMedium.copyWith(color: AppColors.textLight),
        headlineSmall: TextStyles.headlineSmall.copyWith(color: AppColors.textLight),
        titleLarge: TextStyles.titleLarge.copyWith(color: AppColors.textLight),
        titleMedium: TextStyles.titleMedium.copyWith(color: AppColors.textLight),
        titleSmall: TextStyles.titleSmall.copyWith(color: AppColors.textLight),
        bodyLarge: TextStyles.bodyLarge.copyWith(color: AppColors.textLight),
        bodyMedium: TextStyles.bodyMedium.copyWith(color: AppColors.textLight),
        bodySmall: TextStyles.bodySmall.copyWith(color: AppColors.greyLight),
        labelLarge: TextStyles.labelLarge.copyWith(color: AppColors.textLight),
        labelMedium: TextStyles.labelMedium.copyWith(color: AppColors.textLight),
        labelSmall: TextStyles.labelSmall.copyWith(color: AppColors.greyLight),
      ),
    );
  }
}

// lib/core/theme/theme_extensions.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  // Quick access to common colors
  Color get primaryColor => colorScheme.primary;
  Color get backgroundColor => colorScheme.background;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;
  
  // Status colors with context awareness
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get infoColor => AppColors.info;
  
  // DMS specific colors
  Color get salesColor => AppColors.salesPrimary;
  Color get inventoryColor => AppColors.inventoryPrimary;
  Color get orderColor => AppColors.orderPrimary;
  Color get customerColor => AppColors.customerPrimary;
  Color get reportColor => AppColors.reportPrimary;
}