import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDisclaimerKey = 'seen_ai_disclaimer';

/// Управляет флагом "пользователь видел privacy-disclaimer AI-вкладки".
///
/// Намеренно вынесен отдельно от [OpenRouterKeyRepository], чтобы избежать
/// конфликтов при параллельной разработке.
class DisclaimerService {
  const DisclaimerService();

  Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDisclaimerKey) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDisclaimerKey, true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDisclaimerKey, false);
  }
}

final disclaimerServiceProvider = Provider<DisclaimerService>(
  (_) => const DisclaimerService(),
);
