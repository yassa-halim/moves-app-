import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';






















































abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  
  
  
  
  
  
  
  
  
  
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  
  
  
  
  String get login;

  
  
  
  
  String get email;

  
  
  
  
  String get password;

  
  
  
  
  String get forgetPassword;

  
  
  
  
  String get dontHaveAccount;

  
  
  
  
  String get createOne;

  
  
  
  
  String get or;

  
  
  
  
  String get loginWithGoogle;

  
  
  
  
  String get onboardingTitle1;

  
  
  
  
  String get onboardingDesc1;

  
  
  
  
  String get onboardingTitle2;

  
  
  
  
  String get onboardingDesc2;

  
  
  
  
  String get onboardingTitle3;

  
  
  
  
  String get onboardingDesc3;

  
  
  
  
  String get onboardingTitle4;

  
  
  
  
  String get onboardingDesc4;

  
  
  
  
  String get onboardingTitle5;

  
  
  
  
  String get onboardingDesc5;

  
  
  
  
  String get onboardingTitle6;

  
  
  
  
  String get onboardingDesc6;

  
  
  
  
  String get exploreNow;

  
  
  
  
  String get next;

  
  
  
  
  String get back;

  
  
  
  
  String get finish;

  
  
  
  
  String get register;

  
  
  
  
  String get name;

  
  
  
  
  String get confirmPassword;

  
  
  
  
  String get phoneNumber;

  
  
  
  
  String get avatar;

  
  
  
  
  String get alreadyHaveAccount;

  
  
  
  
  String get createAccount;

  
  
  
  
  String get forgetPasswordTitle;

  
  
  
  
  String get verifyEmail;

  
  
  
  
  String get seeMore;

  
  
  
  
  String get action;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
