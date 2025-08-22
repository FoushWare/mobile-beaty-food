import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';

class RecipeManagementScreen extends StatelessWidget {
  const RecipeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الوصفات'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64),
            SizedBox(height: 16),
            Text(
              'إدارة الوصفات قيد التطوير',
              style: TextStyle(fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}