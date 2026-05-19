import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('l10n ARB', () {
    final ru = jsonDecode(File('lib/core/localization/app_ru.arb').readAsStringSync())
        as Map<String, dynamic>;
    final en = jsonDecode(File('lib/core/localization/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;

    bool isKey(String k) => !k.startsWith('@');

    test('ru and en have the same translation keys', () {
      final ruKeys = ru.keys.where(isKey).toSet();
      final enKeys = en.keys.where(isKey).toSet();

      final onlyInRu = ruKeys.difference(enKeys);
      final onlyInEn = enKeys.difference(ruKeys);

      expect(onlyInRu, isEmpty, reason: 'Missing in en: $onlyInRu');
      expect(onlyInEn, isEmpty, reason: 'Missing in ru: $onlyInEn');
    });

    test('every parametric key has a metadata entry with placeholders', () {
      for (final entry in ru.entries) {
        if (!isKey(entry.key)) continue;
        final value = entry.value;
        if (value is! String) continue;
        if (!value.contains('{')) continue;

        final meta = ru['@${entry.key}'];
        expect(meta, isA<Map>(), reason: 'Missing @${entry.key} metadata in ru');
        expect((meta as Map)['placeholders'], isA<Map>(),
            reason: 'Missing placeholders for ${entry.key}');
      }
    });

    test('all values are non-empty strings', () {
      for (final entry in ru.entries) {
        if (!isKey(entry.key)) continue;
        expect(entry.value, isA<String>(), reason: '${entry.key} is not String in ru');
        expect((entry.value as String).trim(), isNotEmpty,
            reason: '${entry.key} is empty in ru');
      }
      for (final entry in en.entries) {
        if (!isKey(entry.key)) continue;
        expect(entry.value, isA<String>(), reason: '${entry.key} is not String in en');
        expect((entry.value as String).trim(), isNotEmpty,
            reason: '${entry.key} is empty in en');
      }
    });
  });
}
