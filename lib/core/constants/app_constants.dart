class AppConstants {
  static const String appName = 'Baty Food';
  static const String appTagline = 'طعم البيت في جيبك';
  
  // API Configuration
  static const String baseUrl = 'https://your-backend-url.render.com/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String selectedUserTypeKey = 'selected_user_type';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Delivery
  static const double freeDeliveryMinimum = 100.0;
  static const double defaultDeliveryFee = 10.0;
  static const double maxDeliveryRadius = 15.0; // km
  
  // Commission
  static const double platformCommissionRate = 0.02; // 2%
  
  // Sample Data Images - Using reliable placeholder service
  static const List<String> sampleRecipeImages = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
    'https://picsum.photos/400/300?random=5',
    'https://picsum.photos/400/300?random=6',
  ];
  
  static const List<String> sampleChefImages = [
    'https://picsum.photos/200/200?random=10',
    'https://picsum.photos/200/200?random=11',
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Border Radius
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double smallBorderRadius = 8.0;
  
  // Spacing
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  // Categories
  static const List<String> recipeCategories = [
    'الكل',
    'أطباق رئيسية',
    'مقبلات',
    'حلويات',
    'مشروبات',
    'سلطات',
    'شوربات',
    'معجنات',
  ];
  
  static const List<String> cuisineTypes = [
    'مصري',
    'شامي',
    'خليجي',
    'مغربي',
    'إيطالي',
    'آسيوي',
    'هندي',
    'تركي',
  ];
}