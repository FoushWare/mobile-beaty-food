import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/models/recipe.dart';

class RecipeManagementScreen extends ConsumerStatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  ConsumerState<RecipeManagementScreen> createState() =>
      _RecipeManagementScreenState();
}

class _RecipeManagementScreenState
    extends ConsumerState<RecipeManagementScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final List<Recipe> _recipes = _getMockRecipes();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredRecipes = _getFilteredRecipes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalyticsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/chef-dashboard/recipe-form'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsOverview(context, theme),

          // Search and Filter Bar
          _buildSearchAndFilter(context, theme, filteredRecipes),

          // Recipes List
          Expanded(
            child: filteredRecipes.isEmpty
                ? _buildEmptyState(context, theme)
                : RefreshIndicator(
                    onRefresh: () async {
                      // TODO: Refresh recipes from API
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        return _buildRecipeCard(
                            context, theme, filteredRecipes[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, ThemeData theme) {
    final totalRecipes = _recipes.length;
    final availableRecipes = _recipes.where((r) => r.isAvailable).length;
    final totalOrders =
        _recipes.fold(0, (sum, recipe) => sum + recipe.orderCount);
    final avgRating = _recipes.isNotEmpty
        ? _recipes.map((r) => r.rating).reduce((a, b) => a + b) /
            _recipes.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.green.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Total Recipes',
              totalRecipes.toString(),
              Icons.restaurant_menu,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Available',
              availableRecipes.toString(),
              Icons.check_circle,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Total Orders',
              totalOrders.toString(),
              Icons.shopping_cart,
              Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Avg Rating',
              avgRating.toStringAsFixed(1),
              Icons.star,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(
      BuildContext context, ThemeData theme, List<Recipe> filteredRecipes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', filteredRecipes.length),
                _buildFilterChip('available', 'Available',
                    _recipes.where((r) => r.isAvailable).length),
                _buildFilterChip('unavailable', 'Unavailable',
                    _recipes.where((r) => !r.isAvailable).length),
                _buildFilterChip('featured', 'Featured',
                    _recipes.where((r) => r.isFeatured).length),
                _buildFilterChip('popular', 'Popular',
                    _recipes.where((r) => r.orderCount > 10).length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.green.withOpacity(0.2),
        checkmarkColor: Colors.green,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRecipeCard(
      BuildContext context, ThemeData theme, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetails(context, recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Recipe Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: recipe.images.isNotEmpty
                          ? Image.network(
                              recipe.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.restaurant,
                                    size: 40, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.restaurant,
                              size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Recipe Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipe.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (recipe.isFeatured)
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recipe.price.toStringAsFixed(0)} ${recipe.currency}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: recipe.isAvailable
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    recipe.isAvailable
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 12,
                                    color: recipe.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe.isAvailable
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: recipe.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.shopping_cart,
                                    size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${recipe.orderCount}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star,
                                    size: 12, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  recipe.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editRecipe(context, recipe),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleAvailability(recipe),
                      icon: Icon(
                        recipe.isAvailable
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 16,
                      ),
                      label: Text(recipe.isAvailable ? 'Hide' : 'Show'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            recipe.isAvailable ? Colors.orange : Colors.green,
                        side: BorderSide(
                          color: (recipe.isAvailable
                                  ? Colors.orange
                                  : Colors.green)
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRecipeAnalytics(context, recipe),
                      icon: const Icon(Icons.analytics, size: 16),
                      label: const Text('Analytics'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: BorderSide(color: Colors.purple.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first recipe to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/chef-dashboard/recipe-form'),
            icon: const Icon(Icons.add),
            label: const Text('Add Recipe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                recipe.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // Recipe details...
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: ${recipe.price} ${recipe.currency}'),
                      Text('Orders: ${recipe.orderCount}'),
                      Text('Rating: ${recipe.rating}'),
                      Text('Available: ${recipe.isAvailable ? 'Yes' : 'No'}'),
                      // Add more details as needed
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editRecipe(BuildContext context, Recipe recipe) {
    context.push('/chef-dashboard/recipe-form', extra: recipe);
  }

  void _toggleAvailability(Recipe recipe) {
    setState(() {
      // TODO: Update recipe availability via API
      // For now, we'll just show a snackbar since we can't modify the recipe directly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${recipe.isAvailable ? 'Hiding' : 'Showing'} ${recipe.title}'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _showRecipeAnalytics(BuildContext context, Recipe recipe) {
    context.push('/chef-dashboard/recipe-analytics', extra: recipe);
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recipe Analytics'),
        content: const Text('View overall recipe performance and insights.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/chef-dashboard/analytics');
            },
            child: const Text('View Analytics'),
          ),
        ],
      ),
    );
  }

  List<Recipe> _getFilteredRecipes() {
    List<Recipe> filtered = _recipes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((recipe) =>
              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              recipe.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'available':
        filtered = filtered.where((recipe) => recipe.isAvailable).toList();
        break;
      case 'unavailable':
        filtered = filtered.where((recipe) => !recipe.isAvailable).toList();
        break;
      case 'featured':
        filtered = filtered.where((recipe) => recipe.isFeatured).toList();
        break;
      case 'popular':
        filtered = filtered.where((recipe) => recipe.orderCount > 10).toList();
        break;
    }

    return filtered;
  }

  static List<Recipe> _getMockRecipes() {
    return [
      Recipe(
        id: '1',
        chefId: 'chef1',
        chefName: 'Chef Ahmed',
        chefImage: 'https://example.com/chef1.jpg',
        title: 'كبسة الدجاج التقليدية',
        description: 'كبسة دجاج تقليدية مع الأرز البسمتي والبهارات',
        ingredients: [
          const Ingredient(name: 'Chicken', quantity: '1', unit: 'kg'),
          const Ingredient(name: 'Rice', quantity: '3', unit: 'cups'),
          const Ingredient(name: 'Spices', quantity: '2', unit: 'tbsp'),
        ],
        instructions: [
          const CookingStep(
              stepNumber: 1, instruction: 'Cook chicken with spices'),
          const CookingStep(stepNumber: 2, instruction: 'Add rice and cook'),
        ],
        price: 45.0,
        currency: 'SAR',
        images: ['https://example.com/kabsa.jpg'],
        cuisineType: 'Arabic',
        category: 'Main Dish',
        preparationTime: 30,
        cookingTime: 60,
        servings: 4,
        difficulty: DifficultyLevel.medium,
        spiceLevel: SpiceLevel.medium,
        dietaryInfo: const DietaryInfo(isHalal: true),
        tags: ['Kabsa', 'Chicken', 'Rice'],
        isAvailable: true,
        isFeatured: true,
        orderCount: 25,
        rating: 4.8,
        totalReviews: 12,
        reviews: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Recipe(
        id: '2',
        chefId: 'chef1',
        chefName: 'Chef Ahmed',
        chefImage: 'https://example.com/chef1.jpg',
        title: 'معجنات بالسبانخ والجبن',
        description: 'معجنات طازجة محشوة بالسبانخ والجبن',
        ingredients: [
          const Ingredient(name: 'Spinach', quantity: '500', unit: 'g'),
          const Ingredient(name: 'Cheese', quantity: '200', unit: 'g'),
          const Ingredient(name: 'Pastry', quantity: '1', unit: 'pack'),
        ],
        instructions: [
          const CookingStep(stepNumber: 1, instruction: 'Prepare filling'),
          const CookingStep(stepNumber: 2, instruction: 'Fill and bake'),
        ],
        price: 25.0,
        currency: 'SAR',
        images: ['https://example.com/pastry.jpg'],
        cuisineType: 'Arabic',
        category: 'Appetizer',
        preparationTime: 20,
        cookingTime: 30,
        servings: 2,
        difficulty: DifficultyLevel.easy,
        spiceLevel: SpiceLevel.mild,
        dietaryInfo: const DietaryInfo(isVegetarian: true, isHalal: true),
        tags: ['Pastry', 'Spinach', 'Vegetarian'],
        isAvailable: true,
        isFeatured: false,
        orderCount: 15,
        rating: 4.5,
        totalReviews: 8,
        reviews: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Recipe(
        id: '3',
        chefId: 'chef1',
        chefName: 'Chef Ahmed',
        chefImage: 'https://example.com/chef1.jpg',
        title: 'شوربة العدس المصرية',
        description: 'شوربة عدس مصرية تقليدية',
        ingredients: [
          const Ingredient(name: 'Lentils', quantity: '1', unit: 'cup'),
          const Ingredient(name: 'Onions', quantity: '2', unit: 'pieces'),
          const Ingredient(name: 'Spices', quantity: '1', unit: 'tbsp'),
        ],
        instructions: [
          const CookingStep(stepNumber: 1, instruction: 'Cook lentils'),
          const CookingStep(
              stepNumber: 2, instruction: 'Add vegetables and spices'),
        ],
        price: 18.0,
        currency: 'SAR',
        images: ['https://example.com/soup.jpg'],
        cuisineType: 'Arabic',
        category: 'Soup',
        preparationTime: 15,
        cookingTime: 45,
        servings: 3,
        difficulty: DifficultyLevel.easy,
        spiceLevel: SpiceLevel.mild,
        dietaryInfo: const DietaryInfo(isVegan: true, isHalal: true),
        tags: ['Soup', 'Lentils', 'Vegan'],
        isAvailable: false,
        isFeatured: false,
        orderCount: 8,
        rating: 4.2,
        totalReviews: 5,
        reviews: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
