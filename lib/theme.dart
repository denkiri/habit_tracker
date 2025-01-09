import "package:flutter/material.dart";
class MaterialTheme {
  final TextTheme textTheme;
  const MaterialTheme(this.textTheme);
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4279374354),
      surfaceTint: Color(4284440158),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281413937),
      onPrimaryContainer: Color(4290887614),
      secondary: Color(4279069995),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284331112),
      onSecondaryContainer: Color(4278196997),
      tertiary: Color(4284244054),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294573038),
      onTertiaryContainer: Color(4283651661),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294834424),
      onSurface: Color(4280032027),
      onSurfaceVariant: Color(4282664776),
      outline: Color(4285823096),
      outlineVariant: Color(4291086279),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281413680),
      inversePrimary: Color(4291348165),
      primaryFixed: Color(4293255905),
      onPrimaryFixed: Color(4279966748),
      primaryFixedDim: Color(4291348165),
      onPrimaryFixedVariant: Color(4282861382),
      secondaryFixed: Color(4288542627),
      onSecondaryFixed: Color(4278198535),
      secondaryFixedDim: Color(4286765706),
      onSecondaryFixedVariant: Color(4278211357),
      tertiaryFixed: Color(4292994263),
      onTertiaryFixed: Color(4279835925),
      tertiaryFixedDim: Color(4291152060),
      onTertiaryFixedVariant: Color(4282730559),
      surfaceDim: Color(4292729304),
      surfaceBright: Color(4294834424),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294439922),
      surfaceContainer: Color(4294045164),
      surfaceContainerHigh: Color(4293650407),
      surfaceContainerHighest: Color(4293255905),
    );
  }




  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4291348165),
      surfaceTint: Color(4291348165),
      onPrimary: Color(4281348144),
      primaryContainer: Color(4279966491),
      onPrimaryContainer: Color(4289242789),
      secondary: Color(4286765706),
      onSecondary: Color(4278204689),
      secondaryContainer: Color(4281173311),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4294967295),
      onTertiary: Color(4281217577),
      tertiaryContainer: Color(4292073161),
      onTertiaryContainer: Color(4282204216),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279505683),
      onSurface: Color(4293255905),
      onSurfaceVariant: Color(4291086279),
      outline: Color(4287533458),
      outlineVariant: Color(4282664776),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293255905),
      inversePrimary: Color(4284440158),
      primaryFixed: Color(4293255905),
      onPrimaryFixed: Color(4279966748),
      primaryFixedDim: Color(4291348165),
      onPrimaryFixedVariant: Color(4282861382),
      secondaryFixed: Color(4288542627),
      onSecondaryFixed: Color(4278198535),
      secondaryFixedDim: Color(4286765706),
      onSecondaryFixedVariant: Color(4278211357),
      tertiaryFixed: Color(4292994263),
      onTertiaryFixed: Color(4279835925),
      tertiaryFixedDim: Color(4291152060),
      onTertiaryFixedVariant: Color(4282730559),
      surfaceDim: Color(4279505683),
      surfaceBright: Color(4282005817),
      surfaceContainerLowest: Color(4279111182),
      surfaceContainerLow: Color(4280032027),
      surfaceContainer: Color(4280295199),
      surfaceContainerHigh: Color(4281018922),
      surfaceContainerHighest: Color(4281676852),
    );
  }
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: lightScheme().brightness,
      colorScheme: lightScheme(),
      textTheme: const TextTheme().apply(
        bodyColor: lightScheme().onSurface,
        displayColor: lightScheme().onSurface,
      ),
      scaffoldBackgroundColor: lightScheme().background,
      canvasColor: lightScheme().surface,
    );
  }

  // Dark theme method
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: darkScheme().brightness,
      colorScheme: darkScheme(),
      textTheme: const TextTheme().apply(
        bodyColor: darkScheme().onSurface,
        displayColor: darkScheme().onSurface,
      ),
      scaffoldBackgroundColor: darkScheme().background,
      canvasColor: darkScheme().surface,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
