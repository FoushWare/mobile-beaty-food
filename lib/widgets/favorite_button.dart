import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';

class FavoriteButton extends ConsumerWidget {
  final String recipeId;
  final double size;
  final Color? color;
  final VoidCallback? onPressed;

  const FavoriteButton({
    super.key,
    required this.recipeId,
    this.size = 24.0,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(recipeId));
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () {
        ref.read(favoritesProvider.notifier).toggleFavorite(recipeId);
        onPressed?.call();
      },
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: size,
        color: isFavorite
            ? (color ?? Colors.red)
            : (color ?? theme.iconTheme.color),
      ),
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}

class FavoriteButtonSmall extends ConsumerWidget {
  final String recipeId;
  final Color? color;
  final VoidCallback? onPressed;

  const FavoriteButtonSmall({
    super.key,
    required this.recipeId,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(recipeId));
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        ref.read(favoritesProvider.notifier).toggleFavorite(recipeId);
        onPressed?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFavorite
              ? (color ?? Colors.red).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isFavorite
              ? (color ?? Colors.red)
              : (color ?? theme.iconTheme.color),
        ),
      ),
    );
  }
}
