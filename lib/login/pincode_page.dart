import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:userapp/main.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:get/get.dart' hide Trans;
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pinput/pinput.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:async';

class PincodePage extends StatefulWidget {
  final String phoneNumber;

  const PincodePage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PincodePageState createState() => _PincodePageState();
}

class _PincodePageState extends State<PincodePage>
    with TickerProviderStateMixin {
  // ignore: unused_field
  String? _verificationCode;
  String verificationID = "";

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  bool isSendLoading = true;
  bool checkPinLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // Timer for resend functionality
  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _startResendTimer();
    // _verifyPhone();
    _getUser();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _resendOTP() {
    if (_canResend) {
      _startResendTimer();
      // Add your resend OTP logic here
      Get.snackbar(
        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "تم الإرسال" : "Sent",
        LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? "تم إرسال رمز التحقق مرة أخرى"
            : "OTP has been sent again",
        backgroundColor: const Color(0xFFFFB300).withOpacity(0.1),
        colorText: const Color(0xFFFFB300),
        icon: const Icon(Ionicons.checkmark_circle, color: Color(0xFFFFB300)),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _timer?.cancel();
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  _getUser() async {
    AppData().checkUserExist(userPhone: widget.phoneNumber).then(
      (value) {
        Get.offAll(() => const MainPage());
        GetStorage().write("currentuser", value);
      },
    );
    setState(() {
      isSendLoading = false;
      checkPinLoading = false;
    });
  }

  Widget _buildLoadingState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppThemes.primaryColor,
                    AppThemes.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Ionicons.time_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? "يرجى الانتظار"
                : "Please Wait",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? "جاري إرسال رمز التحقق..."
                : "Sending verification code...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: 200,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Top curved section with icon and text
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // OTP icon with background
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Ionicons.lock_closed_outline,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "رمز التحقق"
                          : "OTP",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "يرجى إدخال رمز التحقق المرسل إلى رقم جوالك"
                            : "Please enter the OTP sent to your mobile number",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom section with OTP input - Make it scrollable
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  //topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),

                      // Phone number display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Ionicons.phone_portrait_outline,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.phoneNumber,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // OTP Input
                      Pinput(
                        length: 4,
                        focusNode: _pinPutFocusNode,
                        controller: _pinPutController,
                        defaultPinTheme: PinTheme(
                          width: 55,
                          height: 55,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 55,
                          height: 55,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppThemes.primaryColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppThemes.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 55,
                          height: 55,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppThemes.primaryColor,
                                AppThemes.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppThemes.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        pinAnimationType: PinAnimationType.slide,
                        onCompleted: (pin) async {
                          setState(() {
                            checkPinLoading = true;
                          });

                          // Simulate verification delay
                          await Future.delayed(const Duration(seconds: 2));

                          // For demo purposes, accept any 4-digit code
                          _getUser();
                        },
                        onChanged: (value) {
                          setState(() {
                            // Update button state when text changes
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Resend section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "لم تستلم رمز التحقق؟"
                                : "Didn't receive the OTP?",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (_canResend)
                            GestureDetector(
                              onTap: _resendOTP,
                              child: Text(
                                LocalizeAndTranslate.getLanguageCode() == 'ar'
                                    ? "إعادة الإرسال"
                                    : "Resend OTP",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppThemes.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Text(
                              LocalizeAndTranslate.getLanguageCode() == 'ar'
                                  ? "إعادة الإرسال خلال $_resendCountdown ثانية"
                                  : "Resend in $_resendCountdown s",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale:
                                  checkPinLoading ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        (_pinPutController.text.length == 4 ||
                                                checkPinLoading)
                                            ? [
                                                AppThemes.primaryColor,
                                                AppThemes.primaryColor,
                                              ]
                                            : [
                                                Colors.grey.shade300,
                                                Colors.grey.shade400,
                                              ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow:
                                      (_pinPutController.text.length == 4 ||
                                              checkPinLoading)
                                          ? [
                                              BoxShadow(
                                                color: AppThemes.primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        (_pinPutController.text.length == 4 &&
                                                !checkPinLoading)
                                            ? () async {
                                                setState(() {
                                                  checkPinLoading = true;
                                                });
                                                await Future.delayed(
                                                    const Duration(seconds: 2));
                                                _getUser();
                                              }
                                            : null,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Center(
                                      child: checkPinLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              LocalizeAndTranslate
                                                          .getLanguageCode() ==
                                                      'ar'
                                                  ? "تأكيد"
                                                  : "Submit",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: (_pinPutController
                                                            .text.length ==
                                                        4)
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.primaryColor,
      body: isSendLoading ? _buildLoadingState() : _buildOTPState(),
    );
  }
}
