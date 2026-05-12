import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late AnimationController _fadeController;
  
  String _selectedAvatar = AppAssets.avatarBeardHeadphones; // Default
  
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

    // In a real app, we'd initialize the controllers with data from AuthBloc
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
                color: const Color(0xFF1E1E1E), // Dark charcoal
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 40, offset: const Offset(0, -10))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _avatars[index];
                        final isSelected = _selectedAvatar == avatar;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedAvatar = avatar);
                            setStateModal(() {});
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (mounted) Navigator.pop(context);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
                                width: 2,
                              ),
                              color: Colors.black26,
                              boxShadow: isSelected 
                                ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.3), blurRadius: 15)]
                                : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(avatar, fit: BoxFit.cover),
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
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    _HoverScaleIcon(
                      onTap: () => Navigator.pop(context),
                      icon: Icons.arrow_back,
                      color: AppTheme.primaryYellow,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Pick Avatar',
                          style: TextStyle(color: AppTheme.primaryYellow, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for centering
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
                      
                      // Avatar
                      Center(
                        child: GestureDetector(
                          onTap: _showAvatarPickerModal,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
                              ],
                              image: DecorationImage(
                                image: AssetImage(_selectedAvatar),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      // Input Fields
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

                      // Reset Password
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

              // Bottom Action Buttons
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
                          color: const Color(0xFFE50914), // Netflix Red
                          borderRadius: BorderRadius.circular(16),
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
                      onTap: () {},
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const Center(
                          child: Text(
                            'Update Data',
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        color: const Color(0xFF1E1E1E), // Dark charcoal input background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryYellow, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
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
