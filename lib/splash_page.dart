import 'package:get_storage/get_storage.dart';
import 'package:userapp/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:userapp/main.dart';
import 'package:userapp/utils/helpers_replacement.dart'
    show BuildColor, Headline3;
import 'package:userapp/utils/app_themes.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:math' as math;

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _offerController;
  late AnimationController _shimmerController;
  late AnimationController _waveController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoFloatAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _offerSlideAnimation;
  late Animation<double> _offerFadeAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _navigateToNextPage();
  }

  void _initializeAnimations() {
    // Logo animations with enhanced effects
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _logoFloatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Enhanced text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOutCubic,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutExpo,
    ));

    // Advanced loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOutQuart,
    ));

    // Dynamic background animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFFdab45e),
      end: const Color(0xFFc4a052),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOutSine,
    ));

    // Enhanced particle system
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    // Multi-layered pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    // Profit-driving offer animation
    _offerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _offerSlideAnimation = Tween<double>(
      begin: 150.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _offerController,
      curve: Curves.easeOutBack,
    ));

    _offerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _offerController,
      curve: Curves.easeInOutQuint,
    ));

    // Shimmer effect for premium feel
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    // Wave animation for dynamic background
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  void _startAnimations() {
    // Start background and wave animations immediately
    _backgroundController.repeat(reverse: true);
    _particleController.repeat();
    _waveController.repeat();

    // Sequential animation starts for better user experience
    _logoController.forward();

    // Start shimmer effect
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _shimmerController.repeat();
    });

    // Start pulse animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });

    // Start text animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _textController.forward();
    });

    // Start loading animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _loadingController.forward();
    });

    // Start profit offer animation
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) _offerController.forward();
    });
  }

  void _navigateToNextPage() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        if (GetStorage().read("currentuser") != null) {
          Get.offAll(() => const MainPage());
        } else {
          Get.offAll(() => const LoginPage());
        }
      }
    });
  }

  Widget _buildAdvancedParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(25, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 8 + 3;
            final startX =
                random.nextDouble() * MediaQuery.of(context).size.width;
            final startY =
                random.nextDouble() * MediaQuery.of(context).size.height;
            final speed = random.nextDouble() * 0.7 + 0.3;
            final opacity = random.nextDouble() * 0.8 + 0.2;

            final animationValue = (_particleAnimation.value + speed) % 1.0;
            final yPosition = startY -
                (animationValue * MediaQuery.of(context).size.height * 0.4);

            return Positioned(
              left: startX + math.sin(animationValue * 4 * math.pi) * 30,
              top: yPosition,
              child: Opacity(
                opacity: (1.0 - animationValue) * opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        const Color(0xFFdab45e).withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFloatingIcons() {
    return Stack(
      children: [
        // Shopping bag with enhanced animation
        Positioned(
          top: 120,
          left: 30,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.sin(_backgroundController.value * 2 * math.pi) * 15,
                  math.cos(_backgroundController.value * 1.5 * math.pi) * 8,
                ),
                child: Transform.rotate(
                  angle: math.sin(_backgroundController.value * math.pi) * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFdab45e).withOpacity(0.3),
                          const Color(0xFFdab45e).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFdab45e).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Ionicons.bag_handle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Gift box
        Positioned(
          top: 180,
          right: 40,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.cos(_backgroundController.value * 1.8 * math.pi) * 12,
                  math.sin(_backgroundController.value * 2.2 * math.pi) * 10,
                ),
                child: Transform.scale(
                  scale: 1.0 +
                      math.sin(_backgroundController.value * 3 * math.pi) * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFdab45e).withOpacity(0.3),
                          const Color(0xFFdab45e).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFdab45e).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Ionicons.gift,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Star with sparkle effect
        Positioned(
          bottom: 250,
          left: 50,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.sin(_backgroundController.value * 1.3 * math.pi) * 18,
                  math.cos(_backgroundController.value * 1.7 * math.pi) * 12,
                ),
                child: Transform.rotate(
                  angle: _backgroundController.value * 2 * math.pi,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFdab45e).withOpacity(0.4),
                          const Color(0xFFc4a052).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFdab45e).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Ionicons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Cart icon
        Positioned(
          bottom: 320,
          right: 35,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.cos(_waveAnimation.value) * 10,
                  math.sin(_waveAnimation.value * 1.5) * 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFdab45e).withOpacity(0.3),
                        const Color(0xFFc4a052).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFdab45e).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Ionicons.cart,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfitOfferBanner() {
    return AnimatedBuilder(
      animation: _offerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offerSlideAnimation.value),
          child: FadeTransition(
            opacity: _offerFadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFdab45e),
                    const Color(0xFFc4a052),
                    const Color(0xFFb8944a),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFdab45e).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                    spreadRadius: 0.5,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "🔥",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "خصم 70% على الطلب الأول!"
                              : "70% OFF on first order!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "عرض محدود"
                              : "Limited offer",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "🎉",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(_waveAnimation.value),
          size: Size(MediaQuery.of(context).size.width, 200),
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _offerController.dispose();
    _shimmerController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundColorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColorAnimation.value ?? const Color(0xFFdab45e),
                  const Color(0xFFdab45e).withOpacity(0.95),
                  const Color(0xFFc4a052).withOpacity(0.9),
                  const Color(0xFFc4a052),
                  const Color(0xFFb8944a).withOpacity(0.7),
                  const Color(0xFFa58540).withOpacity(0.5),
                ],
                stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Wave background
                 Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildWaveBackground(),
                ), 

                // Advanced particles
                _buildAdvancedParticles(),

                // Floating icons
                _buildFloatingIcons(),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Enhanced Logo with multiple effects
                              AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) {
                                  return AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _logoScaleAnimation.value *
                                            _pulseAnimation.value,
                                        child: Transform.rotate(
                                          angle:
                                              _logoRotateAnimation.value * 0.0,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              math.sin(_logoFloatAnimation
                                                          .value *
                                                      3 *
                                                      math.pi) *
                                                  8,
                                            ),
                                            child: Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  /*    BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    blurRadius: 25,
                                                    offset: const Offset(0, 12),
                                                    spreadRadius: 3,
                                                  ), */
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFFdab45e)
                                                            .withOpacity(0.5),
                                                    blurRadius: 30,
                                                    offset: const Offset(0, 4),
                                                    spreadRadius: 10,
                                                  ),
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFFc4a052)
                                                            .withOpacity(0.3),
                                                    blurRadius: 35,
                                                    offset: const Offset(0, 0),
                                                    spreadRadius: 15,
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Multiple glowing rings
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color(
                                                                0xFFdab45e)
                                                            .withOpacity(0.3),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color(
                                                                0xFFdab45e)
                                                            .withOpacity(0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                  // Shimmer effect overlay
                                                  AnimatedBuilder(
                                                    animation:
                                                        _shimmerAnimation,
                                                    builder: (context, child) {
                                                      return ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(70),
                                                      
                                                      );
                                                    },
                                                  ),
                                                  // Logo image
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            70),
                                                    child: Image.asset(
                                                      'assets/images/sonbol_logo_alpha.png',
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.white,
                                                                const Color(
                                                                    0xFFdab45e),
                                                                const Color(
                                                                    0xFFc4a052),
                                                              ],
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                            Ionicons.storefront,
                                                            size: 70,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // Enhanced text section
                              AnimatedBuilder(
                                animation: _textController,
                                builder: (context, child) {
                                  return SlideTransition(
                                    position: _textSlideAnimation,
                                    child: FadeTransition(
                                      opacity: _textFadeAnimation,
                                      child: Column(
                                        children: [
                                          // Company name with enhanced styling
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white
                                                      .withOpacity(0.15),
                                                  Colors.white
                                                      .withOpacity(0.05),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              "companyName".tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 6,
                                                  ),
                                                  Shadow(
                                                    color: Colors.orange
                                                        .withOpacity(0.3),
                                                    offset:
                                                        const Offset(-1, -1),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Enhanced tagline
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.2),
                                                  Colors.white
                                                      .withOpacity(0.08),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              LocalizeAndTranslate
                                                          .getLanguageCode() ==
                                                      'ar'
                                                  ? "تسوق بذكاء، اربح أكثر، عيش أفضل"
                                                  : "Shop Smart, Earn More, Live Better",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white
                                                    .withOpacity(0.95),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.6,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // Enhanced feature icons
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildEnhancedFeatureIcon(
                                                  Ionicons.flash,
                                                  "Fast",
                                                  Colors.yellow),
                                              const SizedBox(width: 35),
                                              _buildEnhancedFeatureIcon(
                                                  Ionicons.shield_checkmark,
                                                  "Secure",
                                                  Colors.green),
                                              const SizedBox(width: 35),
                                              _buildEnhancedFeatureIcon(
                                                  Ionicons.diamond,
                                                  "Premium",
                                                  Colors.purple),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profit offer banner
                      _buildProfitOfferBanner(),

                      const SizedBox(height: 20),

                      // Enhanced loading section
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _loadingAnimation,
                              builder: (context, child) {
                                return Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Enhanced progress circle
                                        SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: CircularProgressIndicator(
                                            value: _loadingAnimation.value,
                                            strokeWidth: 2.5,
                                            backgroundColor:
                                                Colors.white.withOpacity(0.15),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                        // Percentage with enhanced styling
                                        Text(
                                          "${(_loadingAnimation.value * 100).toInt()}%",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(1, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    /*      // Enhanced loading text
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.03),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        LocalizeAndTranslate
                                                    .getLanguageCode() ==
                                                'ar'
                                            ? "جاري التحضير..."
                                            : "Preparing...",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.3,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                */
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedFeatureIcon(
      IconData icon, String label, Color accentColor) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 +
          30 * math.sin((x / size.width * 2 * math.pi) + animationValue) +
          15 * math.sin((x / size.width * 4 * math.pi) + animationValue * 1.5);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
