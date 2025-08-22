# Baty Food - Flutter Mobile App Development with DreamFlow 🍽️📱

## 🎯 Project Overview

**Baty Food** is a comprehensive food delivery platform that connects home chefs with customers seeking authentic homemade meals. This README provides complete specifications for developing the Flutter mobile applications using DreamFlow.

### 🌟 Core Concept

- **For Customers**: Browse and order authentic homemade dishes from local chefs
- **For Chefs**: Manage recipes, accept orders, and grow their home cooking business
- **Target Market**: Egyptian expatriates and locals seeking authentic home-cooked meals

### 📱 Mobile Apps Required

1. **Customer App**: Browse recipes, place orders, track deliveries
2. **Chef App**: Manage recipes, handle orders, view analytics

---

## 🏗️ Technical Architecture

### Current Tech Stack

- **Backend**: Node.js + Express + MongoDB Atlas
- **Web Frontend**: Next.js + React + shadcn/ui + Tailwind CSS
- **Authentication**: Supabase Auth
- **Database**: MongoDB Atlas (free tier)
- **Storage**: Cloudinary (image hosting)
- **Hosting**: Render.com (backend) + Vercel (frontend)

### Flutter App Requirements

- **Framework**: Flutter 3.10+
- **State Management**: Provider or Bloc
- **HTTP Client**: Dio or http package
- **Local Storage**: SharedPreferences + Hive
- **Navigation**: Go Router
- **UI Framework**: Material Design 3
- **Authentication**: Supabase Flutter SDK
- **Image Handling**: cached_network_image
- **Maps**: Google Maps Flutter
- **Push Notifications**: Firebase Cloud Messaging

---

## 🎨 Design System & UI Requirements

### Color Palette

```dart
// Primary Colors
static const Color primaryOrange = Color(0xFFFF6B35); // Baty Food Orange
static const Color primaryGreen = Color(0xFF4CAF50);  // Success Green
static const Color primaryGold = Color(0xFFFFD700);   // Accent Gold

// Secondary Colors
static const Color backgroundLight = Color(0xFFFAFAFA);
static const Color backgroundDark = Color(0xFF1A1A1A);
static const Color textPrimary = Color(0xFF2C2C2C);
static const Color textSecondary = Color(0xFF666666);
static const Color cardBackground = Color(0xFFFFFFFF);
static const Color borderColor = Color(0xFFE0E0E0);

// Status Colors
static const Color successGreen = Color(0xFF4CAF50);
static const Color warningOrange = Color(0xFFFF9800);
static const Color errorRed = Color(0xFFF44336);
static const Color infoBlue = Color(0xFF2196F3);
```

### Typography

```dart
// Font Family: Cairo (Arabic support) + Inter (English)
static const String primaryFont = 'Cairo';
static const String secondaryFont = 'Inter';

// Text Styles
static const TextStyle heading1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  fontFamily: primaryFont,
);

static const TextStyle heading2 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  fontFamily: primaryFont,
);

static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  fontFamily: primaryFont,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  fontFamily: primaryFont,
);
```

### Component Library

- **Buttons**: Primary, Secondary, Outlined, Text, Floating Action
- **Cards**: Recipe Cards, Order Cards, Chef Profile Cards
- **Input Fields**: Text, Email, Password, Search, Dropdown
- **Navigation**: Bottom Navigation, App Bar, Drawer
- **Lists**: Recipe Lists, Order History, Chef Lists
- **Modals**: Bottom Sheets, Dialogs, Action Sheets
- **Loading States**: Shimmer effects, Progress indicators
- **Empty States**: No recipes, No orders, No connection

---

## 👤 User Types & Authentication

### User Roles

1. **Customer**: Can browse recipes and place orders
2. **Chef**: Can create recipes and manage orders
3. **Admin**: Can manage users and monitor system (web only)

### Authentication Flow

```dart
// Supabase Auth Implementation
class AuthService {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Auth states: unauthenticated, customer, chef
  Future<User?> signUpCustomer(String email, String password, Map<String, dynamic> userData);
  Future<User?> signUpChef(String email, String password, Map<String, dynamic> userData);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
```

### User Registration Data

```dart
// Customer Registration
class CustomerRegistrationData {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final Address deliveryAddress;
  final List<String> dietaryRestrictions;
  final List<String> favoriteCuisines;
  final String spicePreference; // mild, medium, hot
}

// Chef Registration
class ChefRegistrationData {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String bio;
  final List<String> cuisineSpecialties;
  final String kitchenAddress;
  final String profileImage;
  final List<String> certifications;
}
```

---

## 📊 Data Models

### Core Models

```dart
// User Model
class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String profileImage;
  final UserType userType;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final Address address;
  final UserPreferences preferences;
}

// Recipe Model
class Recipe {
  final String id;
  final String chefId;
  final String title;
  final String description;
  final List<Ingredient> ingredients;
  final List<CookingStep> instructions;
  final double price;
  final String currency;
  final List<String> images;
  final String cuisineType;
  final String category;
  final int preparationTime; // minutes
  final int cookingTime; // minutes
  final int servings;
  final DifficultyLevel difficulty;
  final SpiceLevel spiceLevel;
  final DietaryInfo dietaryInfo;
  final NutritionInfo nutritionInfo;
  final List<String> tags;
  final bool isAvailable;
  final bool isFeatured;
  final int orderCount;
  final double rating;
  final int totalReviews;
  final List<Review> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Order Model
class Order {
  final String id;
  final String customerId;
  final String chefId;
  final String recipeId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final OrderStatus status;
  final Address deliveryAddress;
  final String deliveryInstructions;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double commission;
  final DateTime estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final Review? customerReview;
  final Review? chefReview;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Enums
enum UserType { customer, chef, admin }
enum OrderStatus { pending, confirmed, preparing, ready, delivering, delivered, cancelled }
enum PaymentStatus { pending, paid, failed, refunded }
enum PaymentMethod { cash, card, wallet }
enum DifficultyLevel { easy, medium, hard }
enum SpiceLevel { mild, medium, hot, extraHot }
```

---

## 🏠 Customer App Features

### 1. Onboarding & Authentication

- **Splash Screen**: Baty Food branding with loading animation
- **Welcome Screen**: App introduction with key benefits
- **Registration/Login**: Email/password with social auth options
- **Profile Setup**: Delivery address, dietary preferences, cuisine preferences

### 2. Home & Discovery

- **Home Screen**: Featured recipes, nearby chefs, trending dishes
- **Search & Filters**: By cuisine, price range, dietary restrictions, chef rating
- **Categories**: Egyptian, Italian, Asian, Desserts, Healthy, etc.
- **Recommendations**: Based on order history and preferences

### 3. Recipe Browsing

- **Recipe Cards**: Image, title, chef name, rating, price, prep time
- **Recipe Details**: Full description, ingredients, nutrition info, reviews
- **Chef Profile**: Chef bio, specialties, rating, other recipes
- **Photo Gallery**: Multiple recipe images with zoom functionality

### 4. Shopping Cart & Checkout

- **Add to Cart**: Quantity selection with special instructions
- **Cart Management**: Edit quantities, remove items, view total
- **Checkout Flow**: Delivery address, payment method, order summary
- **Order Confirmation**: Order number, estimated delivery time

### 5. Order Management

- **Order Tracking**: Real-time status updates with progress indicators
- **Order History**: Past orders with reorder functionality
- **Push Notifications**: Order confirmations, status updates, delivery alerts
- **Reviews & Ratings**: Rate recipes and chefs after delivery

### 6. Profile & Settings

- **Profile Management**: Edit personal info, delivery addresses
- **Payment Methods**: Manage saved payment methods
- **Preferences**: Dietary restrictions, cuisine preferences, notifications
- **Support**: Help center, contact support, FAQ

### Customer App Screen Flow

```
Splash → Onboarding → Auth → Home → Recipe Browse → Recipe Details → Cart → Checkout → Order Tracking → Profile
```

---

## 👨‍🍳 Chef App Features

### 1. Authentication & Setup

- **Chef Registration**: Extended form with kitchen info and specialties
- **Profile Setup**: Bio, profile photo, cuisine specialties, certifications
- **Kitchen Verification**: Address verification for delivery radius

### 2. Dashboard

- **Overview**: Today's orders, pending requests, earnings summary
- **Quick Actions**: Add new recipe, view pending orders, update availability
- **Analytics Cards**: Order count, rating, total earnings, popular recipes
- **Notifications**: New orders, reviews, payment confirmations

### 3. Recipe Management

- **Recipe Creation**: Step-by-step form with image upload
- **Recipe Library**: Grid view of all recipes with status indicators
- **Recipe Editing**: Update prices, availability, descriptions
- **Photo Management**: Upload multiple high-quality recipe images

### 4. Order Management

- **Order Queue**: Incoming orders with accept/decline options
- **Active Orders**: Current orders with status updates
- **Order Details**: Customer info, special instructions, delivery address
- **Status Updates**: Mark as preparing, ready, completed

### 5. Analytics & Insights

- **Sales Dashboard**: Daily, weekly, monthly revenue charts
- **Popular Recipes**: Best-selling dishes and performance metrics
- **Customer Feedback**: Reviews and ratings analysis
- **Performance Metrics**: Order completion rate, average rating

### 6. Profile & Settings

- **Chef Profile**: Edit bio, specialties, availability hours
- **Kitchen Settings**: Delivery radius, preparation times
- **Earnings**: Payment history, pending payments, withdrawal options
- **Support**: Help resources, contact support

### Chef App Screen Flow

```
Auth → Dashboard → Recipe Management → Order Queue → Order Details → Analytics → Profile
```

---

## 🔌 API Integration

### Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend-url.render.com/api';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String recipes = '/recipes';
  static const String orders = '/orders';
  static const String payments = '/payments';
}
```

### Key API Endpoints

```dart
// Authentication
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh-token

// Recipes
GET /api/recipes?page=1&limit=20&category=egyptian&search=koshary
GET /api/recipes/{id}
POST /api/recipes (chef only)
PUT /api/recipes/{id} (chef only)
DELETE /api/recipes/{id} (chef only)

// Orders
GET /api/orders/customer/{customerId}
GET /api/orders/chef/{chefId}
POST /api/orders
PUT /api/orders/{id}/status
POST /api/orders/{id}/review

// Users
GET /api/users/profile
PUT /api/users/profile
GET /api/users/chefs?near={lat},{lng}&radius=10km
```

### API Service Implementation

```dart
class ApiService {
  final Dio dio;

  ApiService() : dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  // Recipes
  Future<List<Recipe>> getRecipes({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    double? lat,
    double? lng,
  });

  Future<Recipe> getRecipe(String id);

  // Orders
  Future<Order> createOrder(CreateOrderRequest request);
  Future<List<Order>> getCustomerOrders(String customerId);
  Future<List<Order>> getChefOrders(String chefId);

  // Auth
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(RegisterRequest request);
}
```

---

## 🗺️ Location & Delivery

### Location Services

```dart
class LocationService {
  Future<Position> getCurrentLocation();
  Future<List<Address>> searchAddresses(String query);
  Future<double> calculateDistance(LatLng from, LatLng to);
  Future<Duration> estimateDeliveryTime(LatLng from, LatLng to);
}
```

### Delivery Zones

- **Primary**: 5th District, 90 Street, Nasr City
- **Secondary**: Nearby areas within 15km radius
- **Delivery Fee**: 5-10 EGP based on distance
- **Free Delivery**: Orders above 100 EGP

---

## 💳 Payment Integration

### Payment Methods

1. **Cash on Delivery** (Primary)
2. **Credit/Debit Cards** (Future)
3. **Mobile Wallets** (Future)

### Payment Flow

```dart
class PaymentService {
  Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  });

  Future<List<PaymentMethod>> getSavedPaymentMethods();
  Future<void> savePaymentMethod(PaymentMethod method);
}
```

---

## 📱 Push Notifications

### Notification Types

```dart
// Customer Notifications
- Order confirmation
- Order status updates (preparing, ready, on the way)
- Delivery completion
- New recipes from followed chefs
- Promotional offers

// Chef Notifications
- New order received
- Order deadline reminders
- Payment confirmations
- Customer reviews
- Performance updates
```

### Firebase Setup

```dart
class NotificationService {
  Future<void> initialize();
  Future<String?> getDeviceToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> handleNotificationTap(RemoteMessage message);
}
```

---

## 🎯 Key Features & User Stories

### Customer User Stories

1. **As a customer**, I want to browse recipes by cuisine type so I can find my favorite dishes
2. **As a customer**, I want to see chef ratings and reviews so I can make informed decisions
3. **As a customer**, I want to track my order in real-time so I know when it will arrive
4. **As a customer**, I want to save my favorite recipes so I can reorder them easily
5. **As a customer**, I want to filter by dietary restrictions so I can find suitable meals

### Chef User Stories

1. **As a chef**, I want to create detailed recipe listings so customers know what they're ordering
2. **As a chef**, I want to manage my availability so I only receive orders when I can cook
3. **As a chef**, I want to see order analytics so I can understand my business performance
4. **As a chef**, I want to communicate with customers so I can clarify special requests
5. **As a chef**, I want to set my delivery radius so I only get nearby orders

---

## 🎨 UI/UX Guidelines

### Design Principles

1. **Authentic**: Reflects the warmth of home cooking
2. **Simple**: Easy navigation for all age groups
3. **Visual**: High-quality food photography is central
4. **Trustworthy**: Clear chef profiles and reviews
5. **Efficient**: Quick ordering and minimal steps

### Visual Elements

- **Recipe Cards**: Large images, clear pricing, quick info
- **Progress Indicators**: Visual order tracking with icons
- **Rating System**: 5-star system with written reviews
- **Color Coding**: Order status, dietary info, cuisine types
- **Arabic Support**: RTL layout support for Arabic content

### Interaction Patterns

- **Pull to Refresh**: Update recipe lists and order status
- **Swipe Actions**: Quick actions on order and recipe lists
- **Floating Action Button**: Quick add recipe (chef), quick reorder (customer)
- **Bottom Sheets**: Additional info without leaving screen
- **Haptic Feedback**: Confirm actions and button presses

---

## 🚀 Development Phases

### Phase 1: MVP (8 weeks)

**Customer App Core Features:**

- [ ] Authentication & onboarding
- [ ] Recipe browsing with search/filters
- [ ] Recipe details & chef profiles
- [ ] Shopping cart & checkout
- [ ] Order tracking
- [ ] Basic profile management

**Chef App Core Features:**

- [ ] Authentication & chef setup
- [ ] Recipe creation & management
- [ ] Order queue & management
- [ ] Basic dashboard
- [ ] Order status updates

### Phase 2: Enhanced Features (4 weeks)

- [ ] Push notifications
- [ ] Advanced search & recommendations
- [ ] Order history & favorites
- [ ] Reviews & ratings
- [ ] Chef analytics dashboard
- [ ] Multiple payment methods

### Phase 3: Growth Features (4 weeks)

- [ ] Social features (follow chefs)
- [ ] Promotional campaigns
- [ ] Advanced filters & sorting
- [ ] Chat with chef
- [ ] Loyalty program
- [ ] Performance optimizations

---

## 🛠️ Technical Requirements

### Dependencies

```yaml
dependencies:
  flutter: ^3.10.0
  # State Management
  provider: ^6.0.5
  # API & Network
  dio: ^5.3.0
  # Authentication
  supabase_flutter: ^1.10.0
  # UI Components
  material_design_icons_flutter: ^7.0.0
  cached_network_image: ^3.2.0
  # Navigation
  go_router: ^10.0.0
  # Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  # Location
  geolocator: ^9.0.0
  geocoding: ^2.1.0
  # Maps
  google_maps_flutter: ^2.4.0
  # Notifications
  firebase_messaging: ^14.6.0
  # Image
  image_picker: ^1.0.0
  # Utils
  intl: ^0.18.0
  url_launcher: ^6.1.0
```

### Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   ├── recipes/
│   ├── orders/
│   ├── profile/
│   └── notifications/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── services/
└── assets/
    ├── images/
    ├── icons/
    └── fonts/
```

---

## 📈 Analytics & Monitoring

### Key Metrics to Track

```dart
// User Engagement
- Daily/Monthly Active Users
- Session duration
- Feature usage rates
- User retention rates

// Business Metrics
- Order completion rate
- Average order value
- Chef utilization rate
- Customer satisfaction (ratings)

// Technical Metrics
- App crash rate
- API response times
- Push notification delivery rate
- App store ratings
```

### Analytics Implementation

```dart
class AnalyticsService {
  static Future<void> logEvent(String eventName, Map<String, dynamic> parameters);
  static Future<void> setUserProperties(Map<String, dynamic> properties);
  static Future<void> logScreenView(String screenName);
}
```

---

## 🔐 Security & Privacy

### Security Measures

- **API Security**: JWT tokens, request signing
- **Data Encryption**: Sensitive data encryption at rest
- **Input Validation**: Client and server-side validation
- **Rate Limiting**: Prevent API abuse
- **Secure Storage**: Use Flutter secure storage for tokens

### Privacy Compliance

- **Data Collection**: Clear privacy policy
- **User Consent**: Explicit consent for location/notifications
- **Data Retention**: Clear data deletion policies
- **GDPR Compliance**: European user data protection

---

## 🌍 Localization

### Supported Languages

- **Arabic**: Primary language for Egyptian market
- **English**: Secondary language for international users

### Implementation

```dart
class AppLocalizations {
  static const supportedLocales = [
    Locale('ar', 'EG'), // Arabic (Egypt)
    Locale('en', 'US'), // English (US)
  ];

  // Common strings
  String get appTitle => 'Baty Food';
  String get browseRecipes => 'تصفح الوصفات';
  String get orderNow => 'اطلب الآن';
}
```

---

## 🎯 Business Context for DreamFlow

### Target Market

- **Primary**: Egyptian expatriates missing home cooking
- **Secondary**: Local families seeking authentic homemade meals
- **Geographic Focus**: Cairo (5th District, 90 Street, Nasr City)

### Business Model

- **Commission**: 2% commission on each order
- **Delivery Fee**: 5-10 EGP per order
- **Revenue Projection**: 3,480 EGP in first year with 8,700 orders

### Competitive Advantages

1. **Authentic Home Cooking**: Focus on homemade rather than restaurant food
2. **Trusted Chefs**: Verified home chefs with ratings and reviews
3. **Cultural Authenticity**: Designed for Arabic/Egyptian cuisine and culture
4. **Low Commission**: Only 2% vs competitors' 15-30%
5. **Community Focus**: Building relationships between chefs and customers

---

## 📝 Implementation Notes for DreamFlow

### Priority Features

1. **Start with Customer App** - Higher user volume expected
2. **Focus on Recipe Discovery** - Core value proposition
3. **Implement Cash Payment First** - Main payment method in Egypt
4. **Arabic UI Support** - Essential for target market
5. **Offline Capability** - Handle poor internet connectivity

### Technical Considerations

- **Image Optimization**: Cloudinary integration for recipe photos
- **Caching Strategy**: Cache recipes and chef data for offline browsing
- **Performance**: Optimize for mid-range Android devices (common in Egypt)
- **Testing**: Test on various screen sizes and network conditions

### Success Metrics

- **Customer App**: 1000+ downloads in first month
- **Chef App**: 50+ active chefs in launch areas
- **Order Volume**: 100+ orders in first month
- **User Rating**: 4.5+ stars on app stores

---

## 🎨 Visual Design References

### Design Inspiration

- **Food Apps**: Talabat, Uber Eats (for familiarity)
- **Arabic UI**: Right-to-left layouts, Arabic typography
- **Colors**: Warm, food-inspired palette (orange, gold, green)
- **Photography**: High-quality food photography style

### Brand Identity

- **Logo**: "Baty Food" with Arabic calligraphy
- **Tagline**: "طعم البيت في جيبك" (Taste of home in your pocket)
- **Voice**: Warm, familiar, trustworthy, culturally authentic

---

## 🚀 Launch Strategy

### Soft Launch (Month 1)

- Release in Cairo metro area only
- Onboard 20 carefully selected chefs
- Focus on quality and user feedback
- Limited marketing to friends and family

### Public Launch (Month 2)

- Expand to all target areas
- Increase chef recruitment
- Social media marketing campaign
- Influencer partnerships with food bloggers

### Growth Phase (Month 3+)

- User referral program
- Chef incentive programs
- Feature enhancements based on feedback
- Explore new geographic markets

---

**🎯 Ready to build Baty Food with DreamFlow! This comprehensive specification provides everything needed to create authentic, user-friendly mobile apps that connect home chefs with customers craving authentic homemade meals.**

---

_For questions or clarifications, refer to the technical specifications in `/Docs/Technical_specs/` and business plan in `/Docs/Business_plan/` directories._
