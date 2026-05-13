import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late AnimationController _fadeController;
  
  String _selectedAvatar = AppAssets.avatarBeardHeadphones; 
  
  final List<String> _avatars = [
    AppAssets.avatarBeardHeadphones,
    AppAssets.avatarGentleman,
    AppAssets.avatarRedheadGirl,
    AppAssets.avatarBlondeGirl,
    AppAssets.avatarCatEarsGirl,
    AppAssets.avatarDarkBeardMan,
    AppAssets.avatarSunglassesBoy,
    AppAssets.avatarCurlyRedhead,
    AppAssets.avatarHoodieBoy,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'John Safwat');
    _phoneController = TextEditingController(text: '01200000000');
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800),
    )..forward();

    
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated && state.user.name != null) {
      _nameController.text = state.user.name!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showAvatarPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, -10))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Choose Your Avatar',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _avatars[index];
                        final isSelected = _selectedAvatar == avatar;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedAvatar = avatar);
                            setStateModal(() {});
                            Future.delayed(const Duration(milliseconds: 250), () {
                              if (mounted) Navigator.pop(context);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryYellow : Colors.white.withOpacity(0.05),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected 
                                ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.2), blurRadius: 15)]
                                : [],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipOval(
                                child: Image.asset(avatar, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.destructiveRed,
                ),
              );
            }
          },
          child: Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _HoverScaleIcon(
                      onTap: () => Navigator.pop(context),
                      icon: Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 22, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 68),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      
                      
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _showAvatarPickerModal,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.5), width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryYellow.withOpacity(0.15),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    )
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(_selectedAvatar),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _showAvatarPickerModal,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryYellow,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      
                      _buildTextField(
                        controller: _nameController,
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24),

                      
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _HoverScaleButton(
                      onTap: () {},
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914), 
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const Center(
                          child: Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _HoverScaleButton(
                      onTap: () {
                        context.read<AuthBloc>().add(
                          UpdateProfileRequested(
                            name: _nameController.text,
                            phone: _phoneController.text,
                            avatarUrl: _selectedAvatar,
                          ),
                        );
                      },
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryYellow,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryYellow.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Update Data',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primaryYellow, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
}

class _HoverScaleIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _HoverScaleIcon({required this.icon, required this.onTap, required this.color});

  @override
  State<_HoverScaleIcon> createState() => _HoverScaleIconState();
}

class _HoverScaleIconState extends State<_HoverScaleIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
          child: Icon(widget.icon, color: widget.color),
        ),
      ),
    );
  }
}

class _HoverScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverScaleButton({required this.child, required this.onTap});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
