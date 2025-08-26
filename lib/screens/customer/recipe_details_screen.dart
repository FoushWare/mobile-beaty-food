import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baty_bites/models/recipe.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/providers/recipe_provider.dart';
import 'package:baty_bites/providers/cart_provider.dart';
import 'package:baty_bites/widgets/common/app_button.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  Recipe? recipe;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  void _loadRecipe() {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipe = recipeProvider.getRecipeById(widget.recipeId);

    if (recipe == null) {
      // Recipe not found, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipe == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: recipe!.images.isNotEmpty ? recipe!.images.first : '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            actions: [
              Consumer<RecipeProvider>(
                builder: (context, recipeProvider, child) {
                  final isFavorite = recipeProvider.isFavorite(recipe!.id);
                  return IconButton(
                    onPressed: () => recipeProvider.toggleFavorite(recipe!.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : colorScheme.onPrimary,
                    ),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe!.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: colorScheme.onSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe!.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.defaultSpacing),

                  // Description
                  Text(
                    recipe!.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),

                  const SizedBox(height: AppConstants.largeSpacing),

                  // Quick Info
                  _buildQuickInfo(context, theme, colorScheme),

                  const SizedBox(height: AppConstants.largeSpacing),

                  // Ingredients
                  _buildIngredientsSection(context, theme, colorScheme),

                  const SizedBox(height: AppConstants.largeSpacing),

                  // Instructions
                  _buildInstructionsSection(context, theme, colorScheme),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        recipe!.price.toStringAsFixed(0),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'جنيه',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.defaultSpacing),
              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final inCart = cartProvider.hasItem(recipe!.id);
                    final quantity = cartProvider.getQuantity(recipe!.id);

                    if (inCart) {
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.primary),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.defaultBorderRadius),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        cartProvider.updateQuantity(
                                            recipe!.id, quantity - 1),
                                    icon: Icon(
                                      Icons.remove,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        cartProvider.addItem(recipe!),
                                    icon: Icon(
                                      Icons.add,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.smallSpacing),
                          AppButton.primary(
                            text: 'السلة',
                            onPressed: () => AppRouter.push(
                                '${AppRouter.customerHome}/cart'),
                            icon: const Icon(Icons.shopping_cart),
                          ),
                        ],
                      );
                    }

                    return AppButton.primary(
                      text: 'أضف إلى السلة',
                      onPressed: () => cartProvider.addItem(recipe!),
                      isExpanded: true,
                      icon: const Icon(Icons.add_shopping_cart),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.schedule,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe!.totalTime} دقيقة',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'إجمالي الوقت',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.people,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe!.servings} أشخاص',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'عدد الأشخاص',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe!.spiceLevelText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'مستوى الحرارة',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المكونات',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultSpacing),
            child: Column(
              children: recipe!.ingredients.map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallSpacing),
                      Expanded(
                        child: Text(
                          ingredient.displayText,
                          style: theme.textTheme.bodyMedium,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة التحضير',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        ...recipe!.instructions.map((step) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultSpacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step.stepNumber.toString(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.instruction,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        if (step.timeMinutes != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${step.timeMinutes} دقيقة',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
