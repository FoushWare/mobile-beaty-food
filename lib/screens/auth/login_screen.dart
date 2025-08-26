import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/models/auth.dart';
import 'package:baty_bites/widgets/common/app_button.dart';
import 'package:baty_bites/widgets/common/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserType? userType;

  const LoginScreen({
    super.key,
    this.userType,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isResendingOtp = false;
  int _resendCountdown = 0;
  UserType _userType = UserType.customer;

  @override
  void initState() {
    super.initState();
    _userType = widget.userType ?? UserType.customer;
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );

    _fadeAnimations = List.generate(
      4,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          1.0,
          curve: Curves.easeOut,
        ),
      )),
    );

    _slideAnimations = List.generate(
      4,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          1.0,
          curve: Curves.easeOutBack,
        ),
      )),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await ref.read(authProvider.notifier).sendOtp(_phoneController.text);

      if (success) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });

        // Start resend countdown
        _startResendCountdown();

        // Show success message with OTP for development
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'تم إرسال رمز التحقق إلى ${_phoneController.text}\nرمز التحقق: 1234'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          final errorMessage = ref.read(authProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'حدث خطأ أثناء إرسال رمز التحقق'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إرسال رمز التحقق: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyOtp(
          _phoneController.text, _otpController.text);

      if (success) {
        // Navigate to user type selection or home based on user data
        if (mounted) {
          final currentUser = authProvider.currentUser;
          if (currentUser != null && currentUser['userType'] != null) {
            // User already has a type, go to appropriate home
            final userType = currentUser['userType'] as UserType;

            if (userType == UserType.chef) {
              AppRouter.go(AppRouter.chefDashboard);
            } else {
              AppRouter.go(AppRouter.customerHome);
            }
          } else {
            // New user, go to user type selection
            AppRouter.push(AppRouter.userTypeSelection);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'رمز التحقق غير صحيح'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التحقق من الرمز: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });

        if (_resendCountdown <= 0) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResendingOtp = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendOtp(_phoneController.text);

      if (success) {
        _startResendCountdown();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('تم إعادة إرسال رمز التحقق\nرمز التحقق: 1234'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ??
                  'حدث خطأ أثناء إعادة إرسال الرمز'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إعادة إرسال الرمز: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingOtp = false;
        });
      }
    }
  }

  void _goToRegister() {
    AppRouter.push(AppRouter.register, extra: _userType);
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    // Basic phone validation for Egyptian numbers
    if (!RegExp(r'^\+20[0-9]{10}$').hasMatch(value)) {
      return 'الرجاء إدخال رقم هاتف مصري صحيح (+20xxxxxxxxxx)';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رمز التحقق';
    }
    if (value.length != 4) {
      return 'رمز التحقق يجب أن يكون 4 أرقام';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _fadeAnimations[0],
                      child: SlideTransition(
                        position: _slideAnimations[0],
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _userType == UserType.customer
                                    ? Icons.person
                                    : Icons.restaurant,
                                size: 40,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.largeSpacing),
                            Text(
                              _userType == UserType.customer
                                  ? 'تسجيل دخول العميل'
                                  : 'تسجيل دخول الطاهي',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: AppConstants.smallSpacing),
                            Text(
                              _userType == UserType.customer
                                  ? 'اكتشف أشهى الأطباق البيتية'
                                  : 'شارك وصفاتك المميزة مع العالم',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.extraLargeSpacing),

                    // Phone Field
                    FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: SlideTransition(
                        position: _slideAnimations[1],
                        child: AppTextField(
                          labelText: 'رقم الهاتف',
                          hintText: '+201234567890',
                          controller: _phoneController,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: _validatePhone,
                          textInputAction: TextInputAction.done,
                          type: AppTextFieldType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && !value.startsWith('+20')) {
                              _phoneController.text = '+20$value';
                              _phoneController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _phoneController.text.length),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultSpacing),

                    // OTP Field (only show after OTP is sent)
                    if (_otpSent) ...[
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: SlideTransition(
                          position: _slideAnimations[2],
                          child: AppTextField(
                            labelText: 'رمز التحقق',
                            hintText: '1234',
                            controller: _otpController,
                            prefixIcon: const Icon(Icons.security_outlined),
                            validator: _validateOtp,
                            textInputAction: TextInputAction.done,
                            type: AppTextFieldType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallSpacing),

                      // Resend OTP
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resendCountdown > 0 ? null : _resendOtp,
                            child: Text(
                              _resendCountdown > 0
                                  ? 'إعادة الإرسال خلال $_resendCountdown ثانية'
                                  : 'إعادة إرسال الرمز',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _resendCountdown > 0
                                    ? colorScheme.onSurface
                                        .withValues(alpha: 0.5)
                                    : colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.largeSpacing),

                    // Action Button
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: SlideTransition(
                        position: _slideAnimations[3],
                        child: AppButton.primary(
                          text: _otpSent ? 'تأكيد الرمز' : 'إرسال رمز التحقق',
                          onPressed: _otpSent ? _verifyOtp : _sendOtp,
                          isLoading: _isLoading || _isResendingOtp,
                          isExpanded: true,
                          icon: Icon(_otpSent ? Icons.verified : Icons.send),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.largeSpacing),

                    // Register Link
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ليس لديك حساب؟ ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _goToRegister,
                            child: Text(
                              'إنشاء حساب جديد',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.largeSpacing),

                    // Demo Info Card
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: Container(
                        padding:
                            const EdgeInsets.all(AppConstants.defaultSpacing),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تطبيق تجريبي',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'استخدم رقم الهاتف: +201111111111\nرمز التحقق: 1234\nأو أي رقم هاتف مصري صحيح.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                              textDirection: TextDirection.rtl,
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
    );
  }
}
