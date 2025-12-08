import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _animationComplete = false;

  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Logo scale animation (1.2 -> small)
    _logoScaleAnimation = Tween<double>(
      begin: 1.2,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Logo slide animation (0 -> up)
    _logoSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Form fade animation (starts after logo animation)
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) {
            setState(() => _animationComplete = true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await ref
            .read(authRepositoryProvider)
            .signInWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      } else {
        await ref
            .read(authRepositoryProvider)
            .createUserWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Animated logo
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    _logoSlideAnimation.value.dy *
                        MediaQuery.of(context).size.height,
                  ),
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: screenWidth,
                      height: screenWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          // Splash text (shown before animation)
          if (!_animationComplete)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              child: Text(
                'Efficient Living Loading',
                style: AppTextStyles.link.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),

          // Login form (fades in after animation)
          if (_animationComplete)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _formFadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    color: AppColors.cardDark,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLogin ? 'Welcome Back' : 'Create Account',
                            style: AppTextStyles.title,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Password',
                            ),
                            obscureText: true,
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const CircularProgressIndicator()
                          else
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryPurple,
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  child: Text(
                                    _isLogin ? 'Sign In' : 'Sign Up',
                                    style: AppTextStyles.button,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_isLogin)
                                  OutlinedButton(
                                    onPressed: _googleSignIn,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                      side: BorderSide(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    child: Text(
                                      'Sign in with Google',
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _isLogin = !_isLogin),
                                  child: Text(
                                    _isLogin
                                        ? 'New here? Create account'
                                        : 'Have an account? Sign In',
                                    style: AppTextStyles.link,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
