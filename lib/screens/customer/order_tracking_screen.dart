import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/providers/order_provider.dart';
import 'package:baty_bites/models/order.dart';
import 'package:baty_bites/widgets/common/app_button.dart';
import 'package:baty_bites/widgets/common/loading_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        centerTitle: true,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const LoadingWidget();
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في تحميل الطلب',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    onPressed: () {
                      orderProvider.clearError();
                      orderProvider.loadOrderById(widget.orderId);
                    },
                    text: 'إعادة المحاولة',
                  ),
                ],
              ),
            );
          }

          final order = orderProvider.currentOrder;
          if (order == null) {
            return const Center(
              child: Text('الطلب غير موجود'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 24),
                _buildOrderStatus(order),
                const SizedBox(height: 24),
                _buildOrderItems(order),
                const SizedBox(height: 24),
                _buildOrderDetails(order),
                const SizedBox(height: 24),
                if (order.canCancel) _buildCancelButton(orderProvider, order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب رقم #${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.statusText,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ الطلب: ${_formatDate(order.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (order.estimatedDeliveryTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'الوقت المتوقع للتوصيل: ${_formatDate(order.estimatedDeliveryTime!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus(Order order) {
    final steps = [
      {
        'status': OrderStatus.pending,
        'title': 'تم استلام الطلب',
        'icon': Icons.receipt
      },
      {
        'status': OrderStatus.confirmed,
        'title': 'تم تأكيد الطلب',
        'icon': Icons.check_circle
      },
      {
        'status': OrderStatus.preparing,
        'title': 'قيد التحضير',
        'icon': Icons.restaurant
      },
      {
        'status': OrderStatus.ready,
        'title': 'جاهز للتوصيل',
        'icon': Icons.delivery_dining
      },
      {
        'status': OrderStatus.delivered,
        'title': 'تم التوصيل',
        'icon': Icons.home
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة الطلب',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final stepStatus = step['status'] as OrderStatus;
              final isCompleted = order.status.index >= stepStatus.index;
              final isCurrent = order.status == stepStatus;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isCompleted ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                  fontWeight:
                                      isCurrent ? FontWeight.bold : null,
                                ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(height: 4),
                            Text(
                              'جاري العمل على طلبك',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الطلبات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.recipe.images.isNotEmpty
                              ? item.recipe.images.first
                              : '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.fastfood),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.recipe.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'الكمية: ${item.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (item.specialInstructions != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'ملاحظات: ${item.specialInstructions}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} ريال',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الطلب',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'المجموع الفرعي', '${order.subtotal.toStringAsFixed(2)} ريال'),
            _buildDetailRow('الضريبة', '${order.tax.toStringAsFixed(2)} ريال'),
            _buildDetailRow(
                'رسوم التوصيل', '${order.deliveryFee.toStringAsFixed(2)} ريال'),
            const Divider(),
            _buildDetailRow(
              'المجموع الكلي',
              '${order.total.toStringAsFixed(2)} ريال',
              isTotal: true,
            ),
            ...[
              const SizedBox(height: 16),
              _buildDetailRow('عنوان التوصيل', order.deliveryAddress!),
            ],
            if (order.deliveryInstructions != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('تعليمات التوصيل', order.deliveryInstructions!),
            ],
            const SizedBox(height: 8),
            _buildDetailRow('طريقة الدفع', order.paymentMethod ?? 'غير محدد'),
            _buildDetailRow('حالة الدفع', order.paymentStatusText),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : null,
                  color: isTotal ? Theme.of(context).colorScheme.primary : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(OrderProvider orderProvider, Order order) {
    return AppButton.outlined(
      onPressed: () => _showCancelDialog(orderProvider, order),
      text: 'إلغاء الطلب',
    );
  }

  void _showCancelDialog(OrderProvider orderProvider, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await orderProvider.cancelOrder(order.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
