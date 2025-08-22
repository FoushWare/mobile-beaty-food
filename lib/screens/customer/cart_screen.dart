import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/providers/cart_provider.dart';
import 'package:baty_bites/widgets/common/app_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing),
                  Text(
                    'السلة فارغة',
                    style: theme.textTheme.headlineSmall,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppConstants.smallSpacing),
                  Text(
                    'أضف بعض الوصفات اللذيذة إلى سلتك',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  AppButton.primary(
                    text: 'تصفح الوصفات',
                    onPressed: () => AppRouter.pop(),
                    icon: const Icon(Icons.restaurant_menu),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: item.recipe.images.isNotEmpty
                                    ? Image.network(
                                        item.recipe.images.first,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: colorScheme.primaryContainer,
                                            child: Icon(
                                              Icons.restaurant,
                                              color: colorScheme.onPrimaryContainer,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: colorScheme.primaryContainer,
                                        child: Icon(
                                          Icons.restaurant,
                                          color: colorScheme.onPrimaryContainer,
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
                                    item.recipe.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  Text(
                                    'الشيف ${item.recipe.chefName}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.recipe.price.toStringAsFixed(0)} جنيه',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => cartProvider.updateQuantity(
                                    item.recipe.id,
                                    item.quantity - 1,
                                  ),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => cartProvider.addItem(item.recipe),
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Summary
              Container(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المجموع الفرعي:',
                            style: theme.textTheme.bodyLarge,
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            '${cartProvider.subtotal.toStringAsFixed(0)} جنيه',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'رسوم التوصيل:',
                            style: theme.textTheme.bodyMedium,
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            cartProvider.deliveryFee == 0 
                                ? 'مجاني'
                                : '${cartProvider.deliveryFee.toStringAsFixed(0)} جنيه',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cartProvider.deliveryFee == 0 
                                  ? colorScheme.secondary
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المجموع الكلي:',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            '${cartProvider.total.toStringAsFixed(0)} جنيه',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultSpacing),
                      AppButton.primary(
                        text: 'المتابعة للدفع',
                        onPressed: () => AppRouter.push('${AppRouter.customerHome}/checkout'),
                        isExpanded: true,
                        icon: const Icon(Icons.payment),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}