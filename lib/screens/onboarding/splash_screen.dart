import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/services/storage_service.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/models/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimation,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final storageService = await StorageService.getInstance();
      
      // Check if user is logged in
      final token = storageService.getToken();
      final user = storageService.getUser();
      
      if (token != null && user != null) {
        // User is logged in, go to appropriate home screen
        if (user.userType == UserType.chef) {
          AppRouter.go(AppRouter.chefDashboard);
        } else {
          AppRouter.go(AppRouter.customerHome);
        }
      } else if (storageService.isOnboardingCompleted) {
        // Onboarding completed but not logged in
        AppRouter.go(AppRouter.userTypeSelection);
      } else {
        // First time user
        AppRouter.go(AppRouter.welcome);
      }
    } catch (e) {
      // If there's any error, go to welcome screen
      AppRouter.go(AppRouter.welcome);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.secondary.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: AppConstants.extraLargeSpacing),
                    
                    // App Name
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    
                    // Tagline
                    Text(
                      AppConstants.appTagline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppConstants.extraLargeSpacing * 2),
                    
                    // Loading Indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    
                    Text(
                      'جاري التحميل...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}