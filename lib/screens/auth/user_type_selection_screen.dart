import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/services/storage_service.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/models/user.dart';
import 'package:baty_bites/widgets/common/app_button.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen>
    with TickerProviderStateMixin {
  UserType? _selectedUserType;
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );

    _fadeAnimations = List.generate(
      3,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      )),
    );

    _slideAnimations = List.generate(
      3,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.3,
          1.0,
          curve: Curves.easeOutBack,
        ),
      )),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _continueAsCustomer() async {
    await _saveSelection(UserType.customer);
    AppRouter.push(AppRouter.login, extra: UserType.customer);
  }

  Future<void> _continueAsChef() async {
    await _saveSelection(UserType.chef);
    AppRouter.push(AppRouter.login, extra: UserType.chef);
  }

  Future<void> _saveSelection(UserType userType) async {
    final storageService = await StorageService.getInstance();
    await storageService.saveSelectedUserType(userType);
  }

  void _scrollToButton() {
    // Wait a bit for the UI to update, then scroll to show the button
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppConstants.extraLargeSpacing),
                  
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
                              Icons.restaurant_menu,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.largeSpacing),
                          
                          Text(
                            'مرحباً بك في ${AppConstants.appName}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: AppConstants.defaultSpacing),
                          
                          Text(
                            'اختر نوع حسابك للمتابعة',
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
                  
                  const SizedBox(height: AppConstants.extraLargeSpacing * 1.5),
                  
                  // Customer Option
                  FadeTransition(
                    opacity: _fadeAnimations[1],
                    child: SlideTransition(
                      position: _slideAnimations[1],
                      child: _UserTypeCard(
                        icon: Icons.person,
                        title: 'عميل',
                        subtitle: 'أريد طلب طعام بيتي لذيذ',
                        features: [
                          'تصفح الوصفات من طهاة مختلفين',
                          'طلب الطعام مع التوصيل السريع',
                          'تقييم الطهاة والوصفات',
                          'حفظ الوصفات المفضلة',
                        ],
                        isSelected: _selectedUserType == UserType.customer,
                        onTap: () {
                          setState(() {
                            _selectedUserType = UserType.customer;
                          });
                          _scrollToButton();
                        },
                        primaryColor: colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.largeSpacing),
                  
                  // Chef Option
                  FadeTransition(
                    opacity: _fadeAnimations[1],
                    child: SlideTransition(
                      position: _slideAnimations[1],
                      child: _UserTypeCard(
                        icon: Icons.restaurant,
                        title: 'طاهي منزلي',
                        subtitle: 'أريد بيع طعامي البيتي',
                        features: [
                          'إنشاء وإدارة وصفاتك الخاصة',
                          'قبول الطلبات وإدارتها',
                          'متابعة الأرباح والإحصائيات',
                          'التواصل مع العملاء',
                        ],
                        isSelected: _selectedUserType == UserType.chef,
                        onTap: () {
                          setState(() {
                            _selectedUserType = UserType.chef;
                          });
                          _scrollToButton();
                        },
                        primaryColor: colorScheme.secondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.extraLargeSpacing),
                  
                  // Continue Button
                  FadeTransition(
                    opacity: _fadeAnimations[2],
                    child: SlideTransition(
                      position: _slideAnimations[2],
                      child: Column(
                        children: [
                          if (_selectedUserType != null)
                            AppButton.primary(
                              text: 'المتابعة',
                              onPressed: _selectedUserType == UserType.customer
                                  ? _continueAsCustomer
                                  : _continueAsChef,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_forward),
                            ),
                          
                          const SizedBox(height: AppConstants.defaultSpacing),
                          
                          Text(
                            'يمكنك تغيير نوع الحساب لاحقاً من الإعدادات',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      curve: Curves.easeInOut,
      child: Material(
        color: isSelected 
            ? primaryColor.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        elevation: isSelected ? 8 : 2,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected 
                    ? primaryColor
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? primaryColor
                            : primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: isSelected 
                            ? Colors.white
                            : primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 4),
                          
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: primaryColor,
                        size: 24,
                      ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // Features List
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}