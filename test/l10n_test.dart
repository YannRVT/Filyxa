import 'dart:convert';
import 'dart:io';

import 'package:filyxa/app/locale.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) => arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  test('les 6 langues sont déclarées et prises en charge', () {
    expect(supportedLanguages.keys, ['fr', 'en', 'it', 'es', 'pt', 'ro']);
    for (final code in supportedLanguages.keys) {
      expect(AppLocalizations.delegate.isSupported(Locale(code)), isTrue, reason: code);
    }
  });

  test('chaque langue traduit toutes les clés, sans valeur vide', () {
    final reference = _keys(_arb('fr'));
    for (final code in supportedLanguages.keys) {
      final arb = _arb(code);
      expect(_keys(arb), reference, reason: 'clés de $code');
      for (final key in reference) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: '$code.$key');
      }
    }
  });

  test('le roumain utilise les signes ș et ț', () {
    final ro = _arb('ro').values.whereType<String>().join(' ');
    expect(ro, contains('ț'));
    expect(ro, contains('ș'));
  });

  test('la langue de l\'appareil est reprise si elle est prise en charge, sinon le français', () {
    expect(resolveDeviceLocale(const [Locale('ro', 'RO')]), const Locale('ro'));
    expect(resolveDeviceLocale(const [Locale('de'), Locale('it')]), const Locale('it'));
    expect(resolveDeviceLocale(const [Locale('de')]), const Locale('fr'));
    expect(resolveDeviceLocale(null), const Locale('fr'));
  });
}
