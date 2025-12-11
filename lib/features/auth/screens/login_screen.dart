import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neon_button.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Painter covers it
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: CustomPaint(painter: SkyPainter())),

          // Animated logo
          if (!_animationComplete || _isLogin)
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = _animationComplete
                      ? const Offset(0, -1.0)
                      : _logoSlideAnimation.value;
                  final scale = _animationComplete
                      ? 0.5
                      : _logoScaleAnimation.value;

                  return Transform.translate(
                    offset: Offset(0, offset.dy * screenHeight * 0.2),
                    child: Transform.scale(
                      scale: scale,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png', // Assuming we keep the logo or replace it later
                            width: screenWidth * 0.6,
                            height: screenWidth * 0.6,
                            fit: BoxFit.contain,
                          ),
                          if (_animationComplete)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                "PIRATE HOUSE",
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.textInk,
                                  fontSize: 32,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      offset: const Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Splash text
          if (!_animationComplete)
            Positioned(
              bottom: screenHeight * 0.3,
              left: 0,
              right: 0,
              child: Text(
                'HOISTING THE SAILS...',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textInk,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Login form
          if (_animationComplete)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _formFadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundParchment,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.textParchment,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLogin ? 'WELCOME ABOARD!' : 'JOIN THE CREW!',
                        style: AppTextStyles.title.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'EMAIL',
                          hintStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: AppColors.textInk,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.textInk,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primarySea,
                              width: 3,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'PASSWORD',
                          hintStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppColors.textInk,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.textInk,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primarySea,
                              width: 3,
                            ),
                          ),
                        ),
                        obscureText: true,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textInk,
                          ),
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: NeonButton(
                                text: _isLogin ? 'BOARD SHIP' : 'SIGN ARTICLES',
                                onPressed: _submit,
                                glowColor: AppColors.secondaryGold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isLogin)
                              TextButton(
                                onPressed: _googleSignIn,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.g_mobiledata,
                                      size: 32,
                                      color: AppColors.textInk,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SIGN IN WITH GOOGLE',
                                      style: AppTextStyles.button.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isLogin = !_isLogin),
                              child: Text(
                                _isLogin
                                    ? 'NEW RECRUIT? SIGN UP!'
                                    : 'ALREADY CREW? LOG IN!',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.info,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
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
        ],
      ),
    );
  }
}

class SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw Sky Gradient
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF4FC3F7), // Light Blue Sky
        AppColors.primarySea, // Deep Blue Sea
      ],
      stops: const [0.0, 0.7],
    );

    final paintBg = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paintBg);

    // Draw stylized waves at the bottom (Triangles)
    final paintWaves = Paint()
      ..color = AppColors.primarySea
      ..style = PaintingStyle.fill;

    final path = Path();
    double waveHeight = 20.0;
    double waveWidth = 40.0;

    path.moveTo(0, size.height);
    path.lineTo(0, size.height - 100);

    for (double i = 0; i < size.width; i += waveWidth) {
      path.relativeQuadraticBezierTo(waveWidth / 2, -waveHeight, waveWidth, 0);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paintWaves);

    // Draw Sun
    final paintSun = Paint()
      ..color = AppColors.secondaryGold
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.1),
      40,
      paintSun,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
