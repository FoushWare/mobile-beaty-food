import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/models/auth.dart';
import 'package:baty_bites/providers/auth_provider.dart';
import 'package:baty_bites/widgets/common/app_button.dart';
import 'package:baty_bites/widgets/common/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final UserType? userType;

  const RegisterScreen({
    super.key,
    this.userType,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final _formKey = GlobalKey<FormState>();
  UserType _userType = UserType.customer;
  bool _acceptTerms = false;
  final bool _isLoading = false;
  final bool _otpSent = false;
  final bool _isResendingOtp = false;
  final int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _userType = widget.userType ?? UserType.customer;
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );

    _fadeAnimations = List.generate(
      6,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.15,
          1.0,
          curve: Curves.easeOut,
        ),
      )),
    );

    _slideAnimations = List.generate(
      6,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.15,
          1.0,
          curve: Curves.easeOutBack,
        ),
      )),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى الموافقة على الشروط والأحكام'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(_phoneController.text);

    if (success && mounted) {
      // Navigate to appropriate home screen
      if (_userType == UserType.chef) {
        AppRouter.go(AppRouter.chefDashboard);
      } else {
        AppRouter.go(AppRouter.customerHome);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('حدث خطأ أثناء إنشاء الحساب'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _goToLogin() {
    AppRouter.pop();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    if (value.length < 2) {
      return 'الاسم يجب أن يحتوي على حرفين على الأقل';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (value.length < 11) {
      return 'رقم الهاتف يجب أن يحتوي على 11 رقم';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمة المرور غير متطابقة';
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
                                    ? Icons.person_add
                                    : Icons.restaurant_menu,
                                size: 40,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.largeSpacing),
                            Text(
                              _userType == UserType.customer
                                  ? 'إنشاء حساب عميل'
                                  : 'إنشاء حساب طاهي',
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
                                  ? 'انضم إلينا واستمتع بأشهى الأطباق البيتية'
                                  : 'شاركنا وصفاتك المميزة واربح معنا',
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

                    // Full Name Field
                    FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: SlideTransition(
                        position: _slideAnimations[1],
                        child: AppTextField(
                          labelText: 'الاسم الكامل',
                          hintText: 'أدخل اسمك الكامل',
                          controller: _fullNameController,
                          prefixIcon: const Icon(Icons.person_outlined),
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                          required: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultSpacing),

                    // Email Field
                    FadeTransition(
                      opacity: _fadeAnimations[2],
                      child: SlideTransition(
                        position: _slideAnimations[2],
                        child: AppTextField.email(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'example@email.com',
                          controller: _emailController,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: _validateEmail,
                          textInputAction: TextInputAction.next,
                          required: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultSpacing),

                    // Phone Field
                    FadeTransition(
                      opacity: _fadeAnimations[2],
                      child: SlideTransition(
                        position: _slideAnimations[2],
                        child: AppTextField.phone(
                          labelText: 'رقم الهاتف',
                          hintText: '01234567890',
                          controller: _phoneController,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: _validatePhone,
                          textInputAction: TextInputAction.next,
                          required: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultSpacing),

                    // Password Field
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: SlideTransition(
                        position: _slideAnimations[3],
                        child: AppTextField.password(
                          labelText: 'كلمة المرور',
                          hintText: '••••••••',
                          controller: _passwordController,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          validator: _validatePassword,
                          textInputAction: TextInputAction.next,
                          required: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultSpacing),

                    // Confirm Password Field
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: SlideTransition(
                        position: _slideAnimations[3],
                        child: AppTextField.password(
                          labelText: 'تأكيد كلمة المرور',
                          hintText: '••••••••',
                          controller: _confirmPasswordController,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          validator: _validateConfirmPassword,
                          textInputAction: TextInputAction.done,
                          required: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultSpacing),

                    // Terms and Conditions
                    FadeTransition(
                      opacity: _fadeAnimations[4],
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: colorScheme.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptTerms = !_acceptTerms;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: RichText(
                                  textDirection: TextDirection.rtl,
                                  text: TextSpan(
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    children: [
                                      const TextSpan(text: 'أوافق على '),
                                      TextSpan(
                                        text: 'الشروط والأحكام',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' و'),
                                      TextSpan(
                                        text: 'سياسة الخصوصية',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.largeSpacing),

                    // Register Button
                    FadeTransition(
                      opacity: _fadeAnimations[5],
                      child: SlideTransition(
                        position: _slideAnimations[5],
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return AppButton.primary(
                              text: 'إنشاء الحساب',
                              onPressed: _register,
                              isLoading: authProvider.isLoading,
                              isExpanded: true,
                              icon: const Icon(Icons.person_add),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.largeSpacing),

                    // Login Link
                    FadeTransition(
                      opacity: _fadeAnimations[5],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟ ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _goToLogin,
                            child: Text(
                              'تسجيل الدخول',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
