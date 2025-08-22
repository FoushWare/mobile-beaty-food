import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/providers/recipe_provider.dart';
import 'package:baty_bites/providers/cart_provider.dart';
import 'package:baty_bites/providers/auth_provider.dart';
import 'package:baty_bites/widgets/recipe/recipe_card.dart';
import 'package:baty_bites/widgets/common/app_text_field.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _categoryTabController;
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoryTabController = TabController(
      length: AppConstants.recipeCategories.length,
      vsync: this,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );
    _scrollController = ScrollController();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      recipeProvider.loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryTabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.searchRecipes(query);
  }

  void _onCategoryChanged(int index) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.setCategory(AppConstants.recipeCategories[index]);
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
        recipeProvider.searchRecipes('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          _buildAppBar(context, theme, colorScheme),
          
          // Search Bar
          if (_showSearchBar) _buildSearchBar(),
          
          // Categories
          _buildCategories(context, theme, colorScheme),
          
          // Featured Section
          _buildFeaturedSection(context, theme),
          
          // All Recipes
          _buildAllRecipesSection(context, theme),
        ],
      ),
      
      // Floating Action Buttons
      floatingActionButton: _buildFloatingActionButtons(context, colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(context, theme, colorScheme),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً ${user?.fullName ?? 'بك'} 👋',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  'ماذا تريد أن تأكل اليوم؟',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _showSearchBar ? Icons.close : Icons.search,
                color: colorScheme.onPrimary,
              ),
            ),
            IconButton(
              onPressed: () => AppRouter.push('${AppRouter.customerHome}/profile'),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                backgroundImage: user?.profileImage.isNotEmpty == true 
                    ? NetworkImage(user!.profileImage) 
                    : null,
                child: user?.profileImage.isEmpty != false
                    ? Icon(
                        Icons.person,
                        size: 18,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: AppTextField(
          controller: _searchController,
          hintText: 'ابحث عن الوصفات أو الطهاة...',
          prefixIcon: const Icon(Icons.search),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: AppConstants.smallSpacing),
        child: TabBar(
          controller: _categoryTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: theme.textTheme.bodyMedium,
          onTap: _onCategoryChanged,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultSpacing),
          tabs: AppConstants.recipeCategories
              .map((category) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        category,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, ThemeData theme) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        if (recipeProvider.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.largeSpacing),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final featuredRecipes = recipeProvider.featuredRecipes;
        if (featuredRecipes.isEmpty) return const SliverToBoxAdapter();

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: theme.colorScheme.tertiary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الأطباق المميزة',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultSpacing),
                  itemCount: featuredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = featuredRecipes[index];
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: AppConstants.defaultSpacing),
                      child: RecipeCard(recipe: recipe),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllRecipesSection(BuildContext context, ThemeData theme) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final recipes = recipeProvider.filteredRecipes;

        if (recipeProvider.isLoading && recipes.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.largeSpacing),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (recipes.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    Text(
                      'لا توجد وصفات متاحة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Text(
                      'جرب البحث بكلمات أخرى أو تغيير الفلتر',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                  child: Text(
                    'جميع الوصفات (${recipes.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                );
              }

              final recipe = recipes[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultSpacing),
                child: RecipeCard(recipe: recipe),
              );
            },
            childCount: recipes.length + 1,
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) return const SizedBox();

        return FloatingActionButton(
          onPressed: () => AppRouter.push('${AppRouter.customerHome}/cart'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartProvider.itemCount.toString(),
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'المفضلة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'الطلبات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الملف الشخصي',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            // TODO: Navigate to favorites
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('قائمة المفضلة قريباً')),
            );
            break;
          case 2:
            // TODO: Navigate to order history
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تاريخ الطلبات قريباً')),
            );
            break;
          case 3:
            AppRouter.push('${AppRouter.customerHome}/profile');
            break;
        }
      },
    );
  }
}