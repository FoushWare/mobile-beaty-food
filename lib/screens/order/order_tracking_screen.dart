import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_widget.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Load order details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).getOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderState.isLoading
          ? const LoadingWidget(message: 'جاري تحميل تفاصيل الطلب...')
          : orderState.selectedOrder != null
              ? _buildOrderTrackingContent(orderState.selectedOrder!)
              : _buildErrorState(),
    );
  }

  Widget _buildOrderTrackingContent(Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: 24),
          _buildOrderProgress(order),
          const SizedBox(height: 24),
          _buildOrderDetails(order),
          const SizedBox(height: 24),
          _buildOrderItems(order),
          const SizedBox(height: 24),
          _buildDeliveryInfo(order),
          const SizedBox(height: 24),
          _buildActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Card(
      elevation: 2,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ الطلب: ${_formatDate(order.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (order.estimatedDeliveryTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'الوقت المتوقع للتوصيل: ${_formatDate(order.estimatedDeliveryTime!)}',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress(Order order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressTimeline(order),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTimeline(Order order) {
    final steps = [
      {
        'status': 'pending',
        'title': 'تم استلام الطلب',
        'description': 'تم استلام طلبك بنجاح'
      },
      {
        'status': 'confirmed',
        'title': 'تم تأكيد الطلب',
        'description': 'تم تأكيد الطلب من الشيف'
      },
      {
        'status': 'preparing',
        'title': 'جاري التحضير',
        'description': 'الشيف يقوم بتحضير طلبك'
      },
      {
        'status': 'ready',
        'title': 'الطلب جاهز',
        'description': 'تم تحضير طلبك بنجاح'
      },
      {
        'status': 'out_for_delivery',
        'title': 'في الطريق',
        'description': 'الطلب في طريقه إليك'
      },
      {
        'status': 'delivered',
        'title': 'تم التوصيل',
        'description': 'تم توصيل طلبك بنجاح'
      },
    ];

    final currentStepIndex =
        steps.indexWhere((step) => step['status'] == order.status);
    final isCompleted = order.status == 'delivered';

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentStepIndex;
        final isLast = index == steps.length - 1;

        return Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.orange : Colors.grey[300],
                border: Border.all(
                  color: isActive ? Colors.orange : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? Colors.orange : Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 11),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title']!,
                      style: TextStyle(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'المجموع الفرعي', '${order.subtotal.toStringAsFixed(2)} ج.م'),
            _buildDetailRow(
                'رسوم التوصيل', '${order.deliveryFee.toStringAsFixed(2)} ج.م'),
            _buildDetailRow(
                'رسوم الخدمة', '${order.serviceFee.toStringAsFixed(2)} ج.م'),
            const Divider(height: 24),
            _buildDetailRow(
              'الإجمالي',
              '${order.totalAmount.toStringAsFixed(2)} ج.م',
              isTotal: true,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('طريقة الدفع',
                _getPaymentMethodText(order.paymentMethod ?? 'cash')),
            _buildDetailRow(
                'حالة الدفع', _getPaymentStatusText(order.paymentStatus)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الطلبات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.recipeImage.isNotEmpty
                              ? item.recipeImage
                              : 'https://via.placeholder.com/60',
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
                              item.recipeTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الكمية: ${item.quantity}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (item.specialInstructions?.isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 4),
                              Text(
                                'ملاحظات: ${item.specialInstructions}',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

  Widget _buildDeliveryInfo(Order order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات التوصيل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('الشيف', order.chef.fullName),
            _buildDetailRow('رقم الهاتف', order.chef.phone),
            const SizedBox(height: 16),
            const Text(
              'عنوان التوصيل:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.deliveryAddress,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (order.deliveryInstructions?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              const Text(
                'تعليمات التوصيل:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  order.deliveryInstructions!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    return Column(
      children: [
        if (order.status == 'pending') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _cancelOrder(order.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إلغاء الطلب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _contactSupport(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تواصل مع الدعم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على الطلب',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من رقم الطلب أو حاول مرة أخرى',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('العودة'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.orange[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'preparing':
        return 'جاري التحضير';
      case 'ready':
        return 'جاهز';
      case 'out_for_delivery':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً عند التوصيل';
      case 'card':
        return 'بطاقة ائتمان';
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'bank_transfer':
        return 'تحويل بنكي';
      default:
        return method;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'paid':
        return 'مدفوع';
      case 'failed':
        return 'فشل';
      case 'refunded':
        return 'مسترد';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(orderProvider.notifier).cancelOrder(orderId);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    // TODO: Implement contact support functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة التواصل مع الدعم قريباً'),
      ),
    );
  }
}
