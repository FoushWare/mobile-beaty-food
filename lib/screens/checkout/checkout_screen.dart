import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../models/payment.dart';
import '../../providers/cart_provider.dart';
import '../../core/services/order_service.dart';
import '../../core/services/payment_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/app_text_field.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  bool _isLoading = false;
  String? _selectedAddress;

  final List<String> _paymentMethods = [
    'cash',
    'card',
    'wallet',
    'bank_transfer'
  ];

  final List<String> _addresses = [
    'المنزل - شارع النيل، القاهرة',
    'العمل - وسط البلد، القاهرة',
    'الجامعة - مدينة نصر، القاهرة',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddress = _addresses.isNotEmpty ? _addresses[0] : null;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان التوصيل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Group items by chef
      final Map<String, List<CartItem>> chefItems = {};
      for (final item in widget.cartItems) {
        if (!chefItems.containsKey(item.recipe.chefId)) {
          chefItems[item.recipe.chefId] = [];
        }
        chefItems[item.recipe.chefId]!.add(item);
      }

      final orderService = OrderService();
      final paymentService = PaymentService();
      final List<Order> orders = [];

      // Create separate order for each chef
      for (final entry in chefItems.entries) {
        final chefId = entry.key;
        final items = entry.value;

        final orderItems = items
            .map((item) => CreateOrderItemDto(
                  recipeId: item.recipe.id,
                  quantity: item.quantity,
                  specialInstructions: item.specialInstructions,
                ))
            .toList();

        final subtotal = items.fold<double>(
            0, (sum, item) => sum + (item.recipe.price * item.quantity));

        final orderData = CreateOrderDto(
          chefId: chefId,
          items: orderItems,
          subtotal: subtotal,
          deliveryFee: widget.deliveryFee,
          serviceFee: widget.serviceFee,
          totalAmount: subtotal + widget.deliveryFee + widget.serviceFee,
          currency: 'EGP',
          deliveryAddress: {
            'address': _selectedAddress,
            'instructions': _instructionsController.text,
          },
          deliveryInstructions: _instructionsController.text,
          paymentMethod: _selectedPaymentMethod,
        );

        final order = await orderService.createOrder(orderData);
        orders.add(order);

        // Process payment for this order
        final paymentRequest = PaymentRequest(
          orderId: order.id,
          amount: order.totalAmount,
          currency: order.currency,
          method: _getPaymentMethodType(_selectedPaymentMethod),
        );

        final paymentResponse =
            await paymentService.processPayment(paymentRequest);

        if (!paymentResponse.success) {
          throw Exception('Payment failed: ${paymentResponse.message}');
        }

        // Show payment success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment processed: ${paymentResponse.message}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Clear cart after successful order
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تقديم الطلب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to order confirmation
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تقديم الطلب: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  PaymentMethodType _getPaymentMethodType(String method) {
    switch (method) {
      case 'cash':
        return PaymentMethodType.cash;
      case 'card':
        return PaymentMethodType.card;
      case 'wallet':
        return PaymentMethodType.wallet;
      case 'bank_transfer':
        return PaymentMethodType.bankTransfer;
      default:
        return PaymentMethodType.cash;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    _buildDeliveryAddress(),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(),
                    const SizedBox(height: 24),
                    _buildDeliveryInstructions(),
                    const SizedBox(height: 32),
                    _buildPlaceOrderButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.recipe.images.isNotEmpty
                              ? item.recipe.images.first
                              : 'https://via.placeholder.com/50',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'الكمية: ${item.quantity}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (item.specialInstructions?.isNotEmpty == true)
                              Text(
                                'ملاحظات: ${item.specialInstructions}',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${(item.recipe.price * item.quantity).toStringAsFixed(2)} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 32),
            _buildPriceRow('المجموع الفرعي', widget.subtotal),
            _buildPriceRow('رسوم التوصيل', widget.deliveryFee),
            _buildPriceRow('رسوم الخدمة', widget.serviceFee),
            const Divider(height: 16),
            _buildPriceRow(
              'الإجمالي',
              widget.total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
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
            '${amount.toStringAsFixed(2)} ج.م',
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

  Widget _buildDeliveryAddress() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'عنوان التوصيل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._addresses.map((address) => RadioListTile<String>(
                  title: Text(address),
                  value: address,
                  groupValue: _selectedAddress,
                  onChanged: (value) {
                    setState(() {
                      _selectedAddress = value;
                    });
                  },
                  activeColor: Colors.orange,
                )),
            const SizedBox(height: 16),
            const Text(
              'أو إضافة عنوان جديد:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _addressController,
              hintText: 'أدخل عنوان التوصيل',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => RadioListTile<String>(
                  title: Text(_getPaymentMethodText(method)),
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  activeColor: Colors.orange,
                )),
          ],
        ),
      ),
    );
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

  Widget _buildDeliveryInstructions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تعليمات التوصيل (اختياري)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _instructionsController,
              hintText: 'أدخل أي تعليمات خاصة للتوصيل...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'تأكيد الطلب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
