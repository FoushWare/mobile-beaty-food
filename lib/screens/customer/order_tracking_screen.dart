import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64),
            const SizedBox(height: 16),
            Text(
              'تتبع الطلب #$orderId قيد التطوير',
              style: const TextStyle(fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}