import 'package:flutter/material.dart';

/// Единый источник правды для типографики HabitFlow.
/// Названия — Material 3, чтобы любой существующий виджет, который смотрит
/// в Theme.of(context).textTheme, сразу подхватил наш стиль.
const _kFontFamily = null; // системный/SF Pro/Roboto — оставим OS-дефолт

final TextTheme hfTextTheme = const TextTheme(
  // Display — крупные числа на дашборде
  displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, fontFamily: _kFontFamily),
  displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, fontFamily: _kFontFamily),

  // Headlines — заголовки экранов
  headlineLarge:  TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2, fontFamily: _kFontFamily),
  headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, fontFamily: _kFontFamily),
  headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25, fontFamily: _kFontFamily),

  // Titles — карточки, секции
  titleLarge:  TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3, fontFamily: _kFontFamily),
  titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3, fontFamily: _kFontFamily),
  titleSmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, fontFamily: _kFontFamily),

  // Body — основной текст
  bodyLarge:  TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, fontFamily: _kFontFamily),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45, fontFamily: _kFontFamily),
  bodySmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4, fontFamily: _kFontFamily),

  // Labels — кнопки, подписи
  labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, fontFamily: _kFontFamily),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, fontFamily: _kFontFamily),
  labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2, fontFamily: _kFontFamily),
);

extension TextThemeContext on BuildContext {
  TextTheme get tt => Theme.of(this).textTheme;
}
