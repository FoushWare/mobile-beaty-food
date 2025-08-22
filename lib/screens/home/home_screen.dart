import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth.dart';
import '../../models/recipe.dart';
import '../../core/services/recipe_service.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beaty Food'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return IconButton(
                  onPressed: () => authProvider.logout(),
                  icon: const Icon(Icons.logout),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.state == AuthState.initial || authProvider.state == AuthState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (authProvider.state == AuthState.unauthenticated) {
            return _buildUnauthenticatedView(context, authProvider);
          }

          if (authProvider.state == AuthState.authenticated) {
            return _buildAuthenticatedView(context, authProvider);
          }

          if (authProvider.state == AuthState.error) {
            return _buildErrorView(context, authProvider);
          }

          return const Center(
            child: Text('حالة غير معروفة'),
          );
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 100,
            color: Colors.orange,
          ),
          const SizedBox(height: 32),
          const Text(
            'مرحباً بك في Beaty Food',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'منصة توصيل الطعام المنزلية',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomButton(
            onPressed: () {
              Navigator.pushNamed(context, '/phone-verification');
            },
            text: 'ابدأ الآن',
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 24),
          CustomOutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/phone-verification');
            },
            text: 'تسجيل الدخول',
            icon: Icons.login,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView(BuildContext context, AuthProvider authProvider) {
    final recipeService = RecipeService();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Text(
                        authProvider.profileData?.name?.substring(0, 1) ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.profileData?.name ?? 'مستخدم',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.profileData?.email ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getProfileLevelColor(authProvider.currentProfileLevel),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getProfileLevelText(authProvider.currentProfileLevel),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    // Navigate to profile completion
                  },
                  text: 'إكمال الملف الشخصي',
                  icon: Icons.person_add,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomOutlinedButton(
                  onPressed: () {
                    // Navigate to settings
                  },
                  text: 'الإعدادات',
                  icon: Icons.settings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Sample Data Section
          const Text(
            'بيانات تجريبية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Sample Recipes
          const Text(
            'وصفات تجريبية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Recipe>>(
            future: recipeService.getAllRecipes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load recipes',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final recipes = snapshot.data ?? [];
              
              if (recipes.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('No recipes available'),
                  ),
                );
              }
              
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          recipe.image,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant, size: 40),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${recipe.price.toStringAsFixed(0)} ج.م',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.errorMessage ?? 'خطأ غير معروف',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: () {
                authProvider.logout();
              },
              text: 'إعادة المحاولة',
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Color _getProfileLevelColor(ProfileCompletionLevel? level) {
    switch (level) {
      case ProfileCompletionLevel.mobileVerified:
        return Colors.orange;
      case ProfileCompletionLevel.basicProfile:
        return Colors.blue;
      case ProfileCompletionLevel.completeProfile:
        return Colors.green;
      case ProfileCompletionLevel.chefVerified:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getProfileLevelText(ProfileCompletionLevel? level) {
    switch (level) {
      case ProfileCompletionLevel.mobileVerified:
        return 'تم التحقق من الهاتف';
      case ProfileCompletionLevel.basicProfile:
        return 'ملف أساسي';
      case ProfileCompletionLevel.completeProfile:
        return 'ملف مكتمل';
      case ProfileCompletionLevel.chefVerified:
        return 'شيف موثق';
      default:
        return 'غير محدد';
    }
  }
}
