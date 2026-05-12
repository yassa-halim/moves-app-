import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';
import 'forget_password_page.dart';
import '../../../movies/presentation/pages/main_layout.dart';
import 'package:movies/l10n/app_localizations.dart';
import '../../../../core/localization/language_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  void _googleLogin() {
    context.read<AuthBloc>().add(GoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // If l10n is null (before first frame of localization loads), fallback to English text via hardcoding or just return empty for a split second.
    // It's safe to use `!` because MaterialApp is configured.
    final loc = l10n!;
    final isEnglish = context.watch<LanguageCubit>().state.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.destructiveRed),
            );
          } else if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainLayout()),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/Group 44.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 64),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: loc.email,
                        prefixIcon: const Icon(Icons.email, color: Colors.white),
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: loc.password,
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                    ),
                    const SizedBox(height: 8),
                    // Forget Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgetPasswordPage()));
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(loc.forgetPassword, style: const TextStyle(color: AppTheme.primaryYellow, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login Button
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryYellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(loc.login, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Create Account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(loc.dontHaveAccount, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
                          },
                          child: Text(loc.createOne, style: const TextStyle(color: AppTheme.primaryYellow, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // OR Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppTheme.primaryYellow, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(loc.or, style: const TextStyle(color: AppTheme.primaryYellow, fontSize: 14)),
                        ),
                        const Expanded(child: Divider(color: AppTheme.primaryYellow, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Login With Google
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _googleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryYellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.g_mobiledata, color: Colors.black, size: 36), 
                        label: Text(loc.loginWithGoogle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Language Switcher
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          context.read<LanguageCubit>().toggleLanguage();
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryYellow, width: 2),
                          ),
                          child: Stack(
                            children: [
                              // Animated Yellow Circle Background
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: isEnglish ? Alignment.centerLeft : Alignment.centerRight,
                                child: Container(
                                  width: 28, // Matches the inner height exactly (40 - 8 padding = 32, slightly smaller to look good)
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryYellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Flags
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Center(
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/LR.png',
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Center(
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/EG.png',
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
