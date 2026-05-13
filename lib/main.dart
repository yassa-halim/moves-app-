import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_assets.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/movies/data/models/movie_model.dart';

import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'core/localization/language_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movies/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  await Hive.initFlutter();
  Hive.registerAdapter(MovieModelAdapter()); 

  
  await di.init();

  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<LanguageCubit>()),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Movies App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _splashTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            Image.asset(
              AppAssets.splashLogo,
              width: 150, 
              height: 150,
            ),
            const Spacer(),
            
            Image.asset(
              AppAssets.routeLogo,
              width: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'Supervised by Mohamed Nabil',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
