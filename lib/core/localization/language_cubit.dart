import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _languageKey = 'language_code';
  final SharedPreferences _prefs;

  LanguageCubit(this._prefs) : super(_loadInitialLocale(_prefs));

  static Locale _loadInitialLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    return const Locale('en');
  }

  void toggleLanguage() async {
    final newLocale = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    await _prefs.setString(_languageKey, newLocale.languageCode);
    emit(newLocale);
  }
}
