import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/widgets/common/app_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
              'شاشة الدفع قيد التطوير',
              style: TextStyle(fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}