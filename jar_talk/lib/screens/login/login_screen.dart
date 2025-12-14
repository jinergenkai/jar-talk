import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/auth_controller.dart';
import 'dart:ui';

// Specific colors from design
const Color kPrimaryColor = Color(0xFFD47311);
const Color kBackgroundDark = Color(0xFF221910);
const Color kSurfaceDark = Color(0xFF2F2216);
const Color kTextColorDark = Colors.white;
const Color kTextColorSubtle = Color(0xFFC9AD92); // #c9ad92
const Color kInputPlaceholder = Color(0xFF8A7A6B); // #8a7a6b

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _controller = AuthController.instance;

  bool _isLogin = true;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness if needed, but mainly focused on aesthetic match
    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: Stack(
        children: [
          // Background Glow Effect
          // absolute top-0 left-1/2 -translate-x-1/2 w-full h-[300px] bg-primary/10 dark:bg-primary/20 blur-[100px] rounded-full
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(150),
                  ), // Ellipse-ish
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Hero / Brand Section
                  _buildHeroSection(),

                  const SizedBox(height: 32),

                  // Welcome Headline
                  Text(
                    _isLogin ? "Find Your Jars." : "Create Account.",
                    style: const TextStyle(
                      fontSize: 32, // text-3xl
                      fontWeight: FontWeight.w800, // font-extrabold
                      color: kTextColorDark,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Login Form
                  _buildTextField(
                    controller: _emailController,
                    hint: "Email or Username",
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 4),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: kTextColorSubtle,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleAuthAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: kPrimaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isLogin ? "Log In" : "Sign Up",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(
                            color: kInputPlaceholder,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white10)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Login Buttons
                  _buildSocialButton(
                    label: "Continue with Google",
                    iconPath:
                        "assets/icons/google_logo.svg", // Assuming asset or fallback icon
                    isGoogle: true,
                    onTap: () => _controller.signInWithGoogle(),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialButton(
                    label: "Continue with Apple",
                    icon: Icons.apple,
                    onTap: () {
                      // Placeholder
                    },
                  ),

                  const SizedBox(height: 48),

                  // Footer / Switch Auth Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: TextStyle(
                          color: kInputPlaceholder,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? "Sign Up" : "Log In",
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Extra padding for safe area bottom
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAuthAction() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        colorText: Colors.white,
        backgroundColor: kPrimaryColor,
      );
      return;
    }

    if (_isLogin) {
      _controller.signIn(email, password);
    } else {
      _controller.signUp(email, password);
    }
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Current Glow
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor.withOpacity(0.4),
              ),
            ),
            // The image box
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 112, // w-28 = 28 * 4 = 112px
                height: 112,
                color: Colors.black26,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC_l6lyvSH3mPShDhzk5gwNa3BipRyDEpw7c-29ZqMRot657mobZQ5Jp0oKUz7oh1LIPnzTCcxG74StIxwK9LUYtMWf2cKnXhSS6ZqcUviraLC7jC9-3k-fzSsWnJ9qZmPvxLO3yMuDt-rt3Qnhfb-amkWjECiDGQhscoJt3OetZ4OSX4TUWvS_9WEM0ps9UMg6GkdQEudnHW2DFAuYvvaFSDmwxiUGdNLqbQNf1YXPFuYr_gbMC7m4htWSV1fggjYouRS2muIuUFGg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        color: kPrimaryColor,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "DROP A SLIP, BUILD A MEMORY.",
          style: TextStyle(
            color: kTextColorSubtle,
            fontSize: 14,
            fontWeight: FontWeight.w600, // Medium/SemiBold
            letterSpacing: 1.2, // tracking-wide
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(color: kTextColorDark),
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kInputPlaceholder),
          prefixIcon: Icon(icon, color: Colors.grey), // text-slate-400
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required VoidCallback onTap,
    String? iconPath,
    IconData? icon,
    bool isGoogle = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: kSurfaceDark,
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: kTextColorDark,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              // Simple text fallback if asset missing, or network image for logo to allow easy run
              SizedBox(
                width: 20,
                height: 20,
                child: Image.network(
                  "https://lh3.googleusercontent.com/COxitqgJr1sJnIDe8-jiKhxDx1FrYbtRHKJ9z_hELisAlapwE9LUPh6fcXIfb5vwpbMl4xl9H9TRFPc5NOO8Sb3VSgIBrfRYvW6cUA",
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.g_mobiledata, color: Colors.white),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 22, color: Colors.white),

            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
