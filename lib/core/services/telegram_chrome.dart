import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_providers.dart';
import '../config/tokens.dart';
import '../routing/app_router.dart';
import 'theme_service.dart';

/// Яркость, которую сейчас сообщает Telegram (`WebApp.colorScheme`), либо `null`
/// вне Telegram. Когда `themeProvider == ThemeMode.system`, приложение следует
/// за этим значением вместо platform-brightness (см. [HabitFlowApp]).
///
/// Сидируется в `main()` синхронным чтением `colorScheme` и обновляется
/// контроллером [TelegramChrome] по событию `themeChanged`.
final telegramBrightnessProvider = StateProvider<Brightness?>((_) => null);

/// Маршруты-«корни» — на них нативная кнопка «Назад» Telegram скрыта.
/// Всё остальное (push-экраны: детали привычки, формы, под-экраны профиля)
/// считается вложенным и показывает кнопку.
const _rootRoutes = <String>{
  '/',
  '/splash',
  '/onboarding',
  '/today',
  '/habits',
  '/analytics',
  '/ai',
  '/journal',
  '/profile',
};

/// Подключает Mini App к «хрому» Telegram: viewport (`ready`+`expand`),
/// синхронизацию темы (`themeChanged` → brightness + цвет шапки) и нативную
/// кнопку «Назад» (`BackButton`), завязанную на go_router.
///
/// Монтируется через `MaterialApp.router(builder: ...)`, поэтому имеет доступ
/// и к провайдерам, и к роутеру. Вне Telegram все вызовы — no-op.
class TelegramChrome extends ConsumerStatefulWidget {
  const TelegramChrome({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TelegramChrome> createState() => _TelegramChromeState();
}

class _TelegramChromeState extends ConsumerState<TelegramChrome> {
  // Кэшируем роутер в initState: `ref` нельзя использовать в dispose
  // (после анмаунта), а отписаться от listener'а там обязательно нужно.
  late final GoRouter _router;

  VoidCallback? _offTheme;
  VoidCallback? _offBack;
  bool? _backShown;

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
    final tg = ref.read(telegramServiceProvider);
    tg.initChrome();
    _applyChromeColors();
    _offTheme = tg.onThemeChanged(_onTelegramThemeChanged);
    _router.routeInformationProvider.addListener(_syncBackButton);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncBackButton();
    });
  }

  @override
  void dispose() {
    _offTheme?.call();
    _offBack?.call();
    _router.routeInformationProvider.removeListener(_syncBackButton);
    super.dispose();
  }

  void _onTelegramThemeChanged() {
    final brightness = ref.read(telegramServiceProvider).telegramBrightness();
    ref.read(telegramBrightnessProvider.notifier).state = brightness;
    _applyChromeColors();
  }

  Brightness _effectiveBrightness() {
    final mode = ref.read(themeProvider);
    if (mode == ThemeMode.light) return Brightness.light;
    if (mode == ThemeMode.dark) return Brightness.dark;
    return ref.read(telegramBrightnessProvider) ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  /// Красит нативную шапку и фон Telegram под внешнюю поверхность приложения
  /// (scaffold = `bgSecondary`), чтобы край webview не контрастировал с UI.
  void _applyChromeColors() {
    final dark = _effectiveBrightness() == Brightness.dark;
    final bg = dark ? HFTokens.dBgSecondary : HFTokens.lBgSecondary;
    final hex = _hex(bg);
    ref.read(telegramServiceProvider).setChromeColors(
          headerHex: hex,
          backgroundHex: hex,
        );
  }

  void _syncBackButton() {
    if (!mounted) return;
    final path = _router.routeInformationProvider.value.uri.path;
    final pushable = !_rootRoutes.contains(path);
    if (pushable == _backShown) return; // состояние не изменилось
    _backShown = pushable;

    final tg = ref.read(telegramServiceProvider);
    _offBack?.call();
    if (pushable) {
      _offBack = tg.showBackButton(_onBack);
    } else {
      _offBack = null;
      tg.hideBackButton();
    }
  }

  void _onBack() {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go('/today');
    }
  }

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) => widget.child;
}
