import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/loading_widget.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final String orderId;
  final double amount;
  final String currency;

  const PaymentMethodScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.currency,
  });

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  PaymentMethod? _selectedMethod;
  bool _saveForFuture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).loadPaymentMethods();
      ref.read(paymentProvider.notifier).loadSavedPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final availableMethods = ref.watch(paymentMethodsProvider);
    final savedMethods = ref.watch(savedPaymentMethodsProvider);
    final isLoading = ref.watch(paymentLoadingProvider);
    final error = ref.watch(paymentErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const LoadingWidget(message: 'Loading payment methods...')
          : error != null
              ? _buildErrorWidget(error)
              : _buildContent(availableMethods, savedMethods),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading payment methods',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(paymentProvider.notifier).clearError();
              ref.read(paymentProvider.notifier).loadPaymentMethods();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      List<PaymentMethod> availableMethods, List<PaymentMethod> savedMethods) {
    return Column(
      children: [
        // Order Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount'),
                  Text(
                    '${widget.currency} ${widget.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saved Payment Methods
                if (savedMethods.isNotEmpty) ...[
                  Text(
                    'Saved Payment Methods',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...savedMethods
                      .map((method) => _buildPaymentMethodCard(method, true)),
                  const SizedBox(height: 24),
                ],

                // Available Payment Methods
                Text(
                  'Available Payment Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...availableMethods
                    .map((method) => _buildPaymentMethodCard(method, false)),

                const SizedBox(height: 24),

                // Save for future checkbox
                if (_selectedMethod?.type == PaymentMethodType.card) ...[
                  CheckboxListTile(
                    title:
                        const Text('Save this payment method for future use'),
                    value: _saveForFuture,
                    onChanged: (value) {
                      setState(() {
                        _saveForFuture = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),

        // Continue Button
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMethod != null ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue to Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, bool isSaved) {
    final isSelected = _selectedMethod?.id == method.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio button
              Radio<PaymentMethod>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
                activeColor: Colors.orange,
              ),

              const SizedBox(width: 12),

              // Method icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getMethodColor(method.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(method.type),
                  color: _getMethodColor(method.type),
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (isSaved) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Saved',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMethodDescription(method.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return Colors.green;
      case PaymentMethodType.card:
        return Colors.blue;
      case PaymentMethodType.wallet:
        return Colors.orange;
      case PaymentMethodType.bankTransfer:
        return Colors.purple;
    }
  }

  IconData _getMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return Icons.money;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _getMethodDescription(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return 'Pay with cash on delivery';
      case PaymentMethodType.card:
        return 'Pay with credit or debit card';
      case PaymentMethodType.wallet:
        return 'Pay with digital wallet';
      case PaymentMethodType.bankTransfer:
        return 'Pay via bank transfer';
    }
  }

  void _processPayment() async {
    if (_selectedMethod == null) return;

    final request = PaymentRequest(
      orderId: widget.orderId,
      amount: widget.amount,
      currency: widget.currency,
      method: _selectedMethod!.type,
      metadata: {
        'saveForFuture': _saveForFuture,
        'methodId': _selectedMethod!.id,
      },
    );

    final response =
        await ref.read(paymentProvider.notifier).processPayment(request);

    if (response != null && response.success) {
      if (mounted) {
        // Navigate to payment confirmation screen
        context.push('/payment-confirmation/${response.paymentId}');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Payment processing failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
