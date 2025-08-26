import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/recipe.dart';
import '../../models/favorite.dart';
import '../../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'Main Dish',
    'Appetizer',
    'Soup',
    'Dessert',
    'Beverage',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (favoritesState.favorites.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearFavoritesDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Favorites'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          if (favoritesState.favorites.isNotEmpty) _buildCategoryFilter(theme),

          // Favorites List
          Expanded(
            child: _buildFavoritesList(favoritesState, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                final count = _getCategoryCount(category);

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label:
                        Text('${_getCategoryDisplayName(category)} ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.red.withOpacity(0.2),
                    checkmarkColor: Colors.red,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.red : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesState favoritesState, ThemeData theme) {
    if (favoritesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (favoritesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading favorites',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              favoritesState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(favoritesProvider.notifier).loadFavorites();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredFavorites = _getFilteredFavorites(favoritesState.favorites);

    if (filteredFavorites.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(favoritesProvider.notifier).loadFavorites();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredFavorites.length,
        itemBuilder: (context, index) {
          final favorite = filteredFavorites[index];
          return _buildFavoriteCard(context, theme, favorite);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(
      BuildContext context, ThemeData theme, Favorite favorite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to recipe details
          context.push('/recipe-details', extra: favorite.recipe);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Recipe Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: favorite.recipe.images.isNotEmpty
                      ? Image.network(
                          favorite.recipe.images.first,
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
                    Text(
                      favorite.recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${favorite.recipe.price.toStringAsFixed(0)} ${favorite.recipe.currency}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          favorite.recipe.rating.toStringAsFixed(1),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${favorite.recipe.totalTime} min',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Remove from favorites button
              IconButton(
                onPressed: () => _removeFromFavorites(favorite.recipeId),
                icon: const Icon(Icons.favorite, color: Colors.red),
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding recipes to your favorites to see them here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/customer-home');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Recipes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromFavorites(String recipeId) {
    ref.read(favoritesProvider.notifier).removeFromFavorites(recipeId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
            'Are you sure you want to remove all recipes from your favorites? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(favoritesProvider.notifier).clearAllFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  List<Favorite> _getFilteredFavorites(List<Favorite> favorites) {
    if (_selectedCategory == 'all') {
      return favorites;
    }
    return favorites
        .where((favorite) => favorite.recipe.category == _selectedCategory)
        .toList();
  }

  int _getCategoryCount(String category) {
    final favoritesState = ref.read(favoritesProvider);
    if (category == 'all') {
      return favoritesState.favorites.length;
    }
    return favoritesState.favorites
        .where((favorite) => favorite.recipe.category == category)
        .length;
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'Main Dish':
        return 'Main Dishes';
      case 'Appetizer':
        return 'Appetizers';
      case 'Soup':
        return 'Soups';
      case 'Dessert':
        return 'Desserts';
      case 'Beverage':
        return 'Beverages';
      default:
        return category;
    }
  }
}
