import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/favorite_button.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedCuisine = 'all';
  String _selectedDifficulty = 'all';
  String _selectedSpiceLevel = 'all';
  double _maxPrice = 1000.0;
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isHalal = true;
  bool _isGlutenFree = false;
  bool _showFilters = false;

  final List<String> _categories = [
    'all',
    'Main Dish',
    'Appetizer',
    'Soup',
    'Dessert',
    'Beverage',
  ];

  final List<String> _cuisines = [
    'all',
    'Arabic',
    'Egyptian',
    'Lebanese',
    'Turkish',
    'Moroccan',
    'International',
  ];

  final List<String> _difficulties = [
    'all',
    'easy',
    'medium',
    'hard',
  ];

  final List<String> _spiceLevels = [
    'all',
    'mild',
    'medium',
    'hot',
    'extraHot',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProviderState = ref.watch(recipeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
                _showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),

          // Filters Section
          if (_showFilters) _buildFiltersSection(theme),

          // Results
          Expanded(
            child: _buildSearchResults(recipesState, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search recipes, ingredients, or chefs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          _buildFilterSection('Category', _categories, _selectedCategory,
              (value) {
            setState(() => _selectedCategory = value);
          }),

          const SizedBox(height: 16),

          // Cuisine Filter
          _buildFilterSection('Cuisine', _cuisines, _selectedCuisine, (value) {
            setState(() => _selectedCuisine = value);
          }),

          const SizedBox(height: 16),

          // Price Range
          _buildPriceRangeFilter(theme),

          const SizedBox(height: 16),

          // Difficulty and Spice Level
          Row(
            children: [
              Expanded(
                child: _buildFilterSection(
                    'Difficulty', _difficulties, _selectedDifficulty, (value) {
                  setState(() => _selectedDifficulty = value);
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterSection(
                    'Spice Level', _spiceLevels, _selectedSpiceLevel, (value) {
                  setState(() => _selectedSpiceLevel = value);
                }),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dietary Preferences
          _buildDietaryPreferencesFilter(theme),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getDisplayName(option)),
                  selected: isSelected,
                  onSelected: (selected) {
                    onChanged(option);
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.orange.withOpacity(0.2),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.orange : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Max Price: ${_maxPrice.toStringAsFixed(0)} ${_getCurrency()}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxPrice,
          min: 0,
          max: 1000,
          divisions: 100,
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              _maxPrice = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDietaryPreferencesFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Preferences',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildDietaryChip('Vegetarian', _isVegetarian, (value) {
              setState(() => _isVegetarian = value);
            }),
            _buildDietaryChip('Vegan', _isVegan, (value) {
              setState(() => _isVegan = value);
            }),
            _buildDietaryChip('Halal', _isHalal, (value) {
              setState(() => _isHalal = value);
            }),
            _buildDietaryChip('Gluten Free', _isGlutenFree, (value) {
              setState(() => _isGlutenFree = value);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryChip(String label, bool value, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
      labelStyle: TextStyle(
        color: value ? Colors.green : Colors.grey[700],
        fontWeight: value ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSearchResults(RecipeState recipesState, ThemeData theme) {
    if (recipesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredRecipes = _getFilteredRecipes(recipesState.recipes);

    if (filteredRecipes.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredRecipes.length} recipes found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  // TODO: Implement sorting
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'name',
                    child: Text('Sort by Name'),
                  ),
                  const PopupMenuItem(
                    value: 'price',
                    child: Text('Sort by Price'),
                  ),
                  const PopupMenuItem(
                    value: 'rating',
                    child: Text('Sort by Rating'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Recipes List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return _buildRecipeCard(context, theme, recipe);
            },
          ),
        ),
      ],
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
        onTap: () {
          context.push('/customer-home/recipe-details/${recipe.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: recipe.images.isNotEmpty
                    ? Image.network(
                        recipe.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.restaurant,
                              size: 64, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.restaurant,
                        size: 64, color: Colors.grey),
              ),
            ),

            // Recipe Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FavoriteButtonSmall(recipeId: recipe.id),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime} min',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        '${recipe.price.toStringAsFixed(0)} ${recipe.currency}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag(recipe.category, Colors.blue),
                      const SizedBox(width: 8),
                      _buildTag(recipe.cuisineType, Colors.green),
                      if (recipe.dietaryInfo.isVegetarian)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildTag('Vegetarian', Colors.purple),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
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
            Icons.search_off,
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
            'Try adjusting your search criteria or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  List<Recipe> _getFilteredRecipes(List<Recipe> recipes) {
    return recipes.where((recipe) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch = recipe.title.toLowerCase().contains(query) ||
            recipe.description.toLowerCase().contains(query) ||
            recipe.chefName.toLowerCase().contains(query) ||
            recipe.ingredients.any(
                (ingredient) => ingredient.name.toLowerCase().contains(query));

        if (!matchesSearch) return false;
      }

      // Category filter
      if (_selectedCategory != 'all' && recipe.category != _selectedCategory) {
        return false;
      }

      // Cuisine filter
      if (_selectedCuisine != 'all' && recipe.cuisineType != _selectedCuisine) {
        return false;
      }

      // Price filter
      if (recipe.price > _maxPrice) {
        return false;
      }

      // Difficulty filter
      if (_selectedDifficulty != 'all' &&
          recipe.difficulty.name != _selectedDifficulty) {
        return false;
      }

      // Spice level filter
      if (_selectedSpiceLevel != 'all' &&
          recipe.spiceLevel.name != _selectedSpiceLevel) {
        return false;
      }

      // Dietary preferences filters
      if (_isVegetarian && !recipe.dietaryInfo.isVegetarian) {
        return false;
      }

      if (_isVegan && !recipe.dietaryInfo.isVegan) {
        return false;
      }

      if (_isHalal && !recipe.dietaryInfo.isHalal) {
        return false;
      }

      if (_isGlutenFree && !recipe.dietaryInfo.isGlutenFree) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'all';
      _selectedCuisine = 'all';
      _selectedDifficulty = 'all';
      _selectedSpiceLevel = 'all';
      _maxPrice = 1000.0;
      _isVegetarian = false;
      _isVegan = false;
      _isHalal = true;
      _isGlutenFree = false;
    });
  }

  String _getDisplayName(String value) {
    switch (value) {
      case 'all':
        return 'All';
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'mild':
        return 'Mild';
      case 'hot':
        return 'Hot';
      case 'extraHot':
        return 'Extra Hot';
      default:
        return value;
    }
  }

  String _getCurrency() {
    // TODO: Get from user preferences or app settings
    return 'SAR';
  }
}
