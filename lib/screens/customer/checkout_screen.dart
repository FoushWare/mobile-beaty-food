import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/providers/cart_provider.dart';
import 'package:baty_bites/providers/order_provider.dart';
import 'package:baty_bites/providers/auth_provider.dart';
import 'package:baty_bites/models/cart_item.dart';
import 'package:baty_bites/widgets/common/app_button.dart';
import 'package:baty_bites/widgets/common/app_text_field.dart';
import 'package:baty_bites/widgets/common/loading_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'الدفع عند الاستلام', 'icon': Icons.money},
    {'value': 'card', 'label': 'بطاقة ائتمان', 'icon': Icons.credit_card},
    {
      'value': 'wallet',
      'label': 'محفظة رقمية',
      'icon': Icons.account_balance_wallet
    },
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('السلة فارغة'),
                  SizedBox(height: 8),
                  Text('أضف بعض الأطباق إلى سلة التسوق أولاً'),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummary(cartProvider),
                        const SizedBox(height: 24),
                        _buildDeliveryDetails(),
                        const SizedBox(height: 24),
                        _buildPaymentMethod(),
                        const SizedBox(height: 24),
                        _buildOrderItems(cartProvider),
                      ],
                    ),
                  ),
                ),
                _buildCheckoutButton(cartProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    final subtotal = cartProvider.total;
    final tax = subtotal * 0.15; // 15% tax
    final deliveryFee = 10.0; // Fixed delivery fee
    final total = subtotal + tax + deliveryFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الطلب',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('المجموع الفرعي', subtotal),
            _buildSummaryRow('الضريبة (15%)', tax),
            _buildSummaryRow('رسوم التوصيل', deliveryFee),
            const Divider(),
            _buildSummaryRow('المجموع الكلي', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
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
            '${amount.toStringAsFixed(2)} ريال',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : null,
                  color: isTotal ? Theme.of(context).colorScheme.primary : null,
                ),
          ),
          if (isTotal) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${amount.toStringAsFixed(0)} ريال',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل التوصيل',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _addressController,
              labelText: 'عنوان التوصيل',
              hintText: 'أدخل عنوان التوصيل الكامل',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان التوصيل';
                }
                return null;
              },
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _instructionsController,
              labelText: 'تعليمات التوصيل (اختياري)',
              hintText: 'أي تعليمات خاصة للتوصيل',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الدفع',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => RadioListTile<String>(
                  value: method['value'],
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  title: Row(
                    children: [
                      Icon(method['icon']),
                      const SizedBox(width: 12),
                      Text(method['label']),
                    ],
                  ),
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(CartProvider cartProvider) {
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
            ...cartProvider.items.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.recipe.images.isNotEmpty ? item.recipe.images.first : '',
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(2)} ريال',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LoadingWidget(),
              ),
            AppButton.primary(
              onPressed:
                  _isProcessing ? null : () => _processOrder(cartProvider),
              text: 'إتمام الطلب',
              isLoading: _isProcessing,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processOrder(CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final subtotal = cartProvider.total;
      final tax = subtotal * 0.15;
      final deliveryFee = 10.0;
      final total = subtotal + tax + deliveryFee;

      final orderData = {
        'items': cartProvider.items
            .map((item) => {
                  'recipeId': item.recipe.id,
                  'quantity': item.quantity,
                  'price': item.recipe.price,
                  'specialInstructions': item.specialInstructions,
                })
            .toList(),
        'deliveryAddress': _addressController.text.trim(),
        'deliveryInstructions': _instructionsController.text.trim(),
        'paymentMethod': _selectedPaymentMethod,
        'subtotal': subtotal,
        'tax': tax,
        'deliveryFee': deliveryFee,
        'total': total,
      };

      final orderProvider = context.read<OrderProvider>();
      final success = await orderProvider.createOrder(orderData);

      if (success && mounted) {
        // Clear cart after successful order
        cartProvider.clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الطلب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
