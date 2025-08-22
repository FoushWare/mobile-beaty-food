import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';

class ChefDashboardScreen extends StatelessWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الشيف'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppRouter.push('${AppRouter.chefDashboard}/profile'),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64),
            SizedBox(height: 16),
            Text(
              'لوحة تحكم الشيف قيد التطوير',
              style: TextStyle(fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}