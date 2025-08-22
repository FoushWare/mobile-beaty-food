import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baty_bites/models/user.dart';
import 'package:baty_bites/core/services/storage_service.dart';
import 'package:baty_bites/screens/onboarding/splash_screen.dart';
import 'package:baty_bites/screens/onboarding/welcome_screen.dart';
import 'package:baty_bites/screens/auth/user_type_selection_screen.dart';
import 'package:baty_bites/screens/auth/login_screen.dart';
import 'package:baty_bites/screens/auth/register_screen.dart';
import 'package:baty_bites/screens/customer/home_screen.dart';
import 'package:baty_bites/screens/customer/recipe_details_screen.dart';
import 'package:baty_bites/screens/customer/cart_screen.dart';
import 'package:baty_bites/screens/customer/checkout_screen.dart';
import 'package:baty_bites/screens/customer/order_tracking_screen.dart';
import 'package:baty_bites/screens/chef/chef_dashboard_screen.dart';
import 'package:baty_bites/screens/chef/recipe_management_screen.dart';
import 'package:baty_bites/screens/chef/order_queue_screen.dart';
import 'package:baty_bites/screens/shared/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String userTypeSelection = '/user-type-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHome = '/customer-home';
  static const String recipeDetails = '/recipe-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking';
  static const String chefDashboard = '/chef-dashboard';
  static const String recipeManagement = '/recipe-management';
  static const String orderQueue = '/order-queue';
  static const String profile = '/profile';

  static late GoRouter router;

  static void initialize() {
    router = GoRouter(
      initialLocation: splash,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: userTypeSelection,
          builder: (context, state) => const UserTypeSelectionScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) {
            final userType = state.extra as UserType?;
            return LoginScreen(userType: userType);
          },
        ),
        GoRoute(
          path: register,
          builder: (context, state) {
            final userType = state.extra as UserType?;
            return RegisterScreen(userType: userType);
          },
        ),
        GoRoute(
          path: customerHome,
          builder: (context, state) => const CustomerHomeScreen(),
          routes: [
            GoRoute(
              path: 'recipe-details/:id',
              builder: (context, state) {
                final recipeId = state.pathParameters['id']!;
                return RecipeDetailsScreen(recipeId: recipeId);
              },
            ),
            GoRoute(
              path: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: 'checkout',
              builder: (context, state) => const CheckoutScreen(),
            ),
            GoRoute(
              path: 'order-tracking/:id',
              builder: (context, state) {
                final orderId = state.pathParameters['id']!;
                return OrderTrackingScreen(orderId: orderId);
              },
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: chefDashboard,
          builder: (context, state) => const ChefDashboardScreen(),
          routes: [
            GoRoute(
              path: 'recipe-management',
              builder: (context, state) => const RecipeManagementScreen(),
            ),
            GoRoute(
              path: 'order-queue',
              builder: (context, state) => const OrderQueueScreen(),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    // Don't redirect when on splash screen
    if (state.fullPath == splash) {
      return null;
    }

    // For now, we'll use a simple storage check
    // In production, this would check authentication state
    return null;
  }

  static void go(String location, {Object? extra}) {
    router.go(location, extra: extra);
  }

  static void push(String location, {Object? extra}) {
    router.push(location, extra: extra);
  }

  static void pop() {
    router.pop();
  }

  static bool canPop() {
    return router.canPop();
  }
}