import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'package:movies/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<Map<String, String>> _getOnboardingData(AppLocalizations loc) {
    return [
      {
        'title': loc.onboardingTitle1,
        'description': loc.onboardingDesc1,
        'imageBg': AppAssets.onboardingCollage,
        'imageFg': '',
        'buttonText': loc.exploreNow,
      },
      {
        'title': loc.onboardingTitle2,
        'description': loc.onboardingDesc2,
        'imageBg': AppAssets.onboardingImage1Bg,
        'imageFg': AppAssets.onboardingImage1Fg,
        'buttonText': loc.next,
      },
      {
        'title': loc.onboardingTitle3,
        'description': loc.onboardingDesc3,
        'imageBg': AppAssets.onboardingImage2Bg,
        'imageFg': AppAssets.onboardingImage2Fg,
        'buttonText': loc.next,
      },
      {
        'title': loc.onboardingTitle4,
        'description': loc.onboardingDesc4,
        'imageBg': AppAssets.onboardingImage3Bg,
        'imageFg': AppAssets.onboardingImage3Fg,
        'buttonText': loc.next,
      },
      {
        'title': loc.onboardingTitle5,
        'description': loc.onboardingDesc5,
        'imageBg': AppAssets.onboardingImage4Bg,
        'imageFg': AppAssets.onboardingImage4Fg,
        'buttonText': loc.next,
      },
      {
        'title': loc.onboardingTitle6,
        'description': loc.onboardingDesc6,
        'imageBg': AppAssets.onboardingImage5Bg,
        'imageFg': AppAssets.onboardingImage5Fg,
        'buttonText': loc.finish,
      },
    ];
  }

  void _nextPage(int dataLength) {
    if (_currentIndex < dataLength - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loc = l10n!;
    final data = _getOnboardingData(loc);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe, use buttons
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: data.length,
            itemBuilder: (context, index) {
              final bg = data[index]['imageBg']!;
              final fg = data[index]['imageFg']!;
              
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Poster Image Layer (which is fg in our data mapping: image 1.(1) .png)
                  if (fg.isNotEmpty)
                    Image.asset(
                      fg,
                      fit: BoxFit.cover,
                    ),
                    
                  // Shadow Layer (which is bg in our data mapping: image 1.png)
                  Image.asset(
                    bg,
                    fit: BoxFit.cover,
                  ),
                ],
              );
            },
          ),
          
          // Gradient overlay for better text readability
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundDark.withOpacity(0.8),
                    AppTheme.backgroundDark,
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20, 
                32, 
                20, 
                MediaQuery.of(context).padding.bottom + 24, // Responsive padding based on the screen (Home indicator safe area)
              ),
              decoration: BoxDecoration(
                color: _currentIndex == 0 ? Colors.transparent : AppTheme.surfaceDark,
                borderRadius: _currentIndex == 0 
                    ? BorderRadius.zero 
                    : const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data[_currentIndex]['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32, // Perfect match for the large onboarding title
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (data[_currentIndex]['description']!.isNotEmpty)
                    Text(
                      data[_currentIndex]['description']!,
                      style: const TextStyle(
                        color: Colors.white70, // Slightly lighter than grey for better contrast
                        fontSize: 15,
                        height: 1.5, // Line height for breathing room
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55, // Match button height perfectly
                    child: ElevatedButton(
                      onPressed: () => _nextPage(data.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        data[_currentIndex]['buttonText']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_currentIndex > 0) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryYellow,
                          side: const BorderSide(color: AppTheme.primaryYellow, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.back,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
