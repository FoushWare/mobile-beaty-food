import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';

class OrderQueueScreen extends StatelessWidget {
  const OrderQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طوابير الطلبات'),
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
              'طوابير الطلبات قيد التطوير',
              style: TextStyle(fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}