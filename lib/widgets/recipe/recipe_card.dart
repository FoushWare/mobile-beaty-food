import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/models/recipe.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/providers/recipe_provider.dart';
import 'package:baty_bites/providers/cart_provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final bool showAddToCart;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: InkWell(
        onTap: onTap ?? () => AppRouter.push('${AppRouter.customerHome}/recipe-details/${recipe.id}'),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(context, colorScheme),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  _buildTitleAndRating(context, theme),
                  
                  const SizedBox(height: AppConstants.smallSpacing),
                  
                  // Chef Info
                  _buildChefInfo(context, theme, colorScheme),
                  
                  const SizedBox(height: AppConstants.smallSpacing),
                  
                  // Description
                  _buildDescription(context, theme, colorScheme),
                  
                  const SizedBox(height: AppConstants.defaultSpacing),
                  
                  // Tags and Details
                  _buildTagsAndDetails(context, theme, colorScheme),
                  
                  const SizedBox(height: AppConstants.defaultSpacing),
                  
                  // Price and Action
                  _buildPriceAndAction(context, theme, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ColorScheme colorScheme) {
    return Stack(
      children: [
        // Main Image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeBorderRadius),
            topRight: Radius.circular(AppConstants.largeBorderRadius),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: recipe.images.isNotEmpty ? recipe.images.first : '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.primaryContainer,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.primaryContainer,
                child: Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        
        // Favorite Button
        Positioned(
          top: AppConstants.smallSpacing,
          right: AppConstants.smallSpacing,
          child: Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              final isFavorite = recipeProvider.isFavorite(recipe.id);
              return Material(
                color: Colors.white.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => recipeProvider.toggleFavorite(recipe.id),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Featured Badge
        if (recipe.isFeatured)
          Positioned(
            top: AppConstants.smallSpacing,
            left: AppConstants.smallSpacing,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: colorScheme.onTertiary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'مميز',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleAndRating(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            recipe.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(width: AppConstants.smallSpacing),
        _buildRatingChip(context),
      ],
    );
  }

  Widget _buildRatingChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 2),
          Text(
            recipe.rating.toStringAsFixed(1),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChefInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: recipe.chefImage.isNotEmpty 
              ? CachedNetworkImageProvider(recipe.chefImage) 
              : null,
          child: recipe.chefImage.isEmpty
              ? Icon(
                  Icons.person,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                )
              : null,
        ),
        const SizedBox(width: AppConstants.smallSpacing),
        Text(
          'الشيف ${recipe.chefName}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Text(
      recipe.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildTagsAndDetails(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: AppConstants.smallSpacing,
      runSpacing: AppConstants.smallSpacing / 2,
      children: [
        _buildInfoChip(
          context,
          icon: Icons.schedule,
          text: '${recipe.totalTime} د',
          color: colorScheme.outline,
        ),
        _buildInfoChip(
          context,
          icon: Icons.people,
          text: '${recipe.servings} أشخاص',
          color: colorScheme.outline,
        ),
        _buildInfoChip(
          context,
          icon: Icons.local_fire_department,
          text: recipe.spiceLevelText,
          color: recipe.spiceLevel == SpiceLevel.hot || recipe.spiceLevel == SpiceLevel.extraHot
              ? Colors.red.withValues(alpha: 0.7)
              : colorScheme.outline,
        ),
        if (recipe.cuisineType.isNotEmpty)
          _buildInfoChip(
            context,
            icon: Icons.restaurant,
            text: recipe.cuisineType,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndAction(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${recipe.price.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'جنيه',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              '${recipe.totalReviews} تقييم',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        
        // Add to Cart Button
        if (showAddToCart)
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final inCart = cartProvider.hasItem(recipe.id);
              final quantity = cartProvider.getQuantity(recipe.id);

              if (inCart) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => cartProvider.updateQuantity(recipe.id, quantity - 1),
                        icon: Icon(
                          Icons.remove,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Text(
                        quantity.toString(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => cartProvider.addItem(recipe),
                        icon: Icon(
                          Icons.add,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ElevatedButton.icon(
                onPressed: () => cartProvider.addItem(recipe),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultSpacing,
                    vertical: AppConstants.smallSpacing,
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: Text(
                  'أضف',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}