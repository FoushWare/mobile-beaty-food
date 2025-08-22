import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/services/storage_service.dart';
import 'package:baty_bites/core/services/sample_data_service.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/models/user.dart';
import 'package:baty_bites/widgets/common/app_button.dart';
import 'package:baty_bites/widgets/common/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  final UserType? userType;

  const LoginScreen({
    super.key,
    this.userType,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  UserType _userType = UserType.customer;

  @override
  void initState() {
    super.initState();
    _userType = widget.userType ?? UserType.customer;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, create a sample user
      final sampleUsers = SampleDataService.getSampleChefs();
      final user = _userType == UserType.customer 
          ? User(
              id: 'customer1',
              fullName: 'أحمد محمد',
              email: _emailController.text,
              phone: '+201234567890',
              profileImage: '',
              userType: UserType.customer,
              createdAt: DateTime.now(),
              isVerified: true,
            )
          : sampleUsers.first.copyWith(
              email: _emailController.text,
            );

      // Save user data
      final storageService = await StorageService.getInstance();
      await storageService.saveToken('sample_token_${DateTime.now().millisecondsSinceEpoch}');
      await storageService.saveUser(user);

      if (mounted) {
        // Navigate to appropriate home screen
        if (_userType == UserType.chef) {
          AppRouter.go(AppRouter.chefDashboard);
        } else {
          AppRouter.go(AppRouter.customerHome);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الدخول: ${e.toString()}'),
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

  void _goToRegister() {
    AppRouter.push(AppRouter.register, extra: _userType);
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل';
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
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.extraLargeSpacing),
                    
                    // Email Field
                    FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: SlideTransition(
                        position: _slideAnimations[1],
                        child: AppTextField.email(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'example@email.com',
                          controller: _emailController,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: _validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.defaultSpacing),
                    
                    // Password Field
                    FadeTransition(
                      opacity: _fadeAnimations[2],
                      child: SlideTransition(
                        position: _slideAnimations[2],
                        child: AppTextField.password(
                          labelText: 'كلمة المرور',
                          hintText: '••••••••',
                          controller: _passwordController,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          validator: _validatePassword,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.smallSpacing),
                    
                    // Forgot Password
                    FadeTransition(
                      opacity: _fadeAnimations[2],
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('سيتم إضافة هذه الميزة قريباً'),
                              ),
                            );
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.largeSpacing),
                    
                    // Login Button
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: SlideTransition(
                        position: _slideAnimations[3],
                        child: AppButton.primary(
                          text: 'تسجيل الدخول',
                          onPressed: _login,
                          isLoading: _isLoading,
                          isExpanded: true,
                          icon: const Icon(Icons.login),
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
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
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
                              'يمكنك استخدام أي بريد إلكتروني وكلمة مرور للتجربة.\nسيتم إنشاء حساب تجريبي تلقائياً.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.8),
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