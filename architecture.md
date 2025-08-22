# Baty Food - Mobile App Architecture

## Project Overview
Baty Food is a comprehensive food delivery platform connecting home chefs with customers seeking authentic homemade meals, targeting Egyptian expatriates and locals.

## Technical Architecture

### Core Technologies
- **Framework**: Flutter 3.6+
- **State Management**: Provider pattern
- **Navigation**: Go Router
- **Local Storage**: Shared Preferences + Hive
- **HTTP Client**: Dio for API calls
- **UI Framework**: Material Design 3

### Project Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart (updated with Baty Food colors)
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_endpoints.dart
│   ├── utils/
│   │   └── helpers.dart
│   └── services/
│       ├── api_service.dart
│       ├── storage_service.dart
│       └── notification_service.dart
├── models/
│   ├── user.dart
│   ├── recipe.dart
│   ├── order.dart
│   └── chef.dart
├── providers/
│   ├── auth_provider.dart
│   ├── recipe_provider.dart
│   └── order_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── user_type_selection_screen.dart
│   ├── onboarding/
│   │   ├── splash_screen.dart
│   │   └── welcome_screen.dart
│   ├── customer/
│   │   ├── home_screen.dart
│   │   ├── recipe_details_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   └── order_tracking_screen.dart
│   ├── chef/
│   │   ├── chef_dashboard_screen.dart
│   │   ├── recipe_management_screen.dart
│   │   ├── order_queue_screen.dart
│   │   └── chef_analytics_screen.dart
│   └── shared/
│       └── profile_screen.dart
└── widgets/
    ├── common/
    │   ├── app_button.dart
    │   ├── app_card.dart
    │   ├── app_text_field.dart
    │   └── loading_indicator.dart
    ├── recipe/
    │   ├── recipe_card.dart
    │   └── recipe_list.dart
    └── order/
        ├── order_card.dart
        └── order_status_indicator.dart
```

## Core Features Implementation

### Phase 1: MVP (Customer App Core)
1. **Authentication & Onboarding**
   - Splash screen with Baty Food branding
   - User type selection (Customer/Chef)
   - Registration/Login with email
   - Profile setup

2. **Recipe Discovery & Browsing**
   - Home screen with featured recipes
   - Search and filter functionality
   - Category-based browsing
   - Recipe cards with images and details

3. **Recipe Details & Chef Profiles**
   - Detailed recipe view with ingredients
   - Chef profile information
   - Rating and review system
   - Photo gallery

4. **Shopping Cart & Checkout**
   - Add to cart functionality
   - Cart management (edit quantities)
   - Simple checkout flow
   - Order confirmation

5. **Order Management**
   - Basic order tracking
   - Order history
   - Order status updates

### Phase 2: Enhanced Features
1. **Chef Dashboard**
   - Recipe creation and management
   - Order queue management
   - Basic analytics
   
2. **Advanced Features**
   - Push notifications
   - Reviews and ratings
   - Favorites system
   - Search improvements

## Data Models

### Core Entities
- **User**: ID, name, email, type, profile info
- **Recipe**: ID, chef_id, title, description, price, images, cuisine_type
- **Order**: ID, customer_id, recipe_id, status, total_price, created_at
- **Chef**: Extends User with specialties, rating, kitchen_address

## Color Palette (Updated Theme)
Following Baty Food brand guidelines:
- **Primary Orange**: #FF6B35 (Baty Food Orange)
- **Primary Green**: #4CAF50 (Success/Action)  
- **Accent Gold**: #FFD700 (Highlights)
- **Background Light**: #FAFAFA
- **Text Primary**: #2C2C2C

## Key Technical Decisions

1. **State Management**: Provider for simplicity and team familiarity
2. **Navigation**: Go Router for type-safe routing
3. **API Integration**: Dio with interceptors for auth and error handling
4. **Local Storage**: Hive for offline recipe caching
5. **Images**: Network images with caching
6. **Offline Support**: Cache recipes and user preferences

## Development Approach

1. **Component-First**: Build reusable widgets
2. **Mobile-First**: Optimize for mobile experience
3. **Performance**: Implement lazy loading and caching
4. **Arabic Support**: RTL layout support for Arabic content
5. **Accessibility**: High contrast colors and readable text

## Success Metrics

- **Performance**: App startup < 3 seconds
- **User Experience**: Smooth 60fps animations
- **Offline**: Browse cached recipes without network
- **Arabic Support**: Full RTL layout support
- **Accessibility**: WCAG 2.1 AA compliance

## Implementation Priority

1. ✅ Update theme with Baty Food colors
2. ✅ Create core data models
3. ✅ Build reusable UI components  
4. ✅ Implement customer user flow
5. ✅ Add chef functionality
6. ✅ Integrate with backend APIs
7. ✅ Add local storage and caching
8. ✅ Test and polish UX

The architecture focuses on building a robust, scalable MVP that can grow into the full Baty Food platform while maintaining excellent performance and user experience.