import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/services/storage_service.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/widgets/common/app_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'اكتشف أطباق بيتية أصيلة',
      subtitle: 'تذوق أشهى الأكلات المصرية والعربية من أيدي طهاة منازل موهوبين',
      image: AppConstants.sampleRecipeImages[0],
      emoji: '🍽️',
    ),
    OnboardingPage(
      title: 'طهاة معتمدون وموثوقون',
      subtitle: 'جميع طهاتنا معتمدون ومختارون بعناية لضمان أفضل تجربة طعام',
      image: AppConstants.sampleChefImages[0],
      emoji: '👨‍🍳',
    ),
    OnboardingPage(
      title: 'توصيل سريع لبابك',
      subtitle: 'احصل على طعامك المفضل في أسرع وقت ممكن في المناطق المدعومة',
      image: AppConstants.sampleRecipeImages[1],
      emoji: '🚗',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );

    _slideAnimations = List.generate(
      3,
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
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final storageService = await StorageService.getInstance();
    await storageService.setOnboardingCompleted();
    
    if (mounted) {
      AppRouter.go(AppRouter.userTypeSelection);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.shortAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultSpacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  // Page Indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: AppConstants.shortAnimation,
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'تخطي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimations[0],
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.largeSpacing),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Emoji
                              SlideTransition(
                                position: _slideAnimations[0],
                                child: Text(
                                  page.emoji,
                                  style: const TextStyle(fontSize: 80),
                                ),
                              ),
                              const SizedBox(height: AppConstants.largeSpacing),
                              
                              // Image
                              SlideTransition(
                                position: _slideAnimations[1],
                                child: Container(
                                  width: size.width * 0.7,
                                  height: size.width * 0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                                    child: Image.network(
                                      page.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: colorScheme.primaryContainer,
                                          child: Icon(
                                            Icons.image,
                                            size: 60,
                                            color: colorScheme.onPrimaryContainer,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppConstants.largeSpacing * 1.5),
                              
                              // Title
                              SlideTransition(
                                position: _slideAnimations[2],
                                child: Text(
                                  page.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              const SizedBox(height: AppConstants.defaultSpacing),
                              
                              // Subtitle
                              SlideTransition(
                                position: _slideAnimations[2],
                                child: Text(
                                  page.subtitle,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: AppButton.primary(
                text: _currentPage == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                onPressed: _nextPage,
                isExpanded: true,
                icon: Icon(
                  _currentPage == _pages.length - 1 
                      ? Icons.rocket_launch 
                      : Icons.arrow_forward,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String image;
  final String emoji;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.emoji,
  });
}