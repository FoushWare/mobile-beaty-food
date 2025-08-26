import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/loading_widget.dart';

class PaymentConfirmationScreen extends ConsumerStatefulWidget {
  final String paymentId;

  const PaymentConfirmationScreen({
    super.key,
    required this.paymentId,
  });

  @override
  ConsumerState<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState
    extends ConsumerState<PaymentConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).loadPaymentById(widget.paymentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final payment = ref.watch(currentPaymentProvider);
    final isLoading = ref.watch(paymentLoadingProvider);
    final error = ref.watch(paymentErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const LoadingWidget(message: 'Processing payment...')
          : error != null
              ? _buildErrorWidget(error)
              : payment != null
                  ? _buildConfirmationContent(payment)
                  : const Center(child: Text('Payment not found')),
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
            'Payment Error',
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
              ref
                  .read(paymentProvider.notifier)
                  .loadPaymentById(widget.paymentId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent(Payment payment) {
    final isSuccess = payment.status == PaymentStatus.completed;
    final isPending = payment.status == PaymentStatus.pending ||
        payment.status == PaymentStatus.processing;
    final isFailed = payment.status == PaymentStatus.failed ||
        payment.status == PaymentStatus.cancelled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _getStatusColor(payment.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(payment.status),
              size: 60,
              color: _getStatusColor(payment.status),
            ),
          ),

          const SizedBox(height: 24),

          // Status Title
          Text(
            _getStatusTitle(payment.status),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(payment.status),
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Status Message
          Text(
            _getStatusMessage(payment.status),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Payment Details Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Payment ID', payment.id),
                  _buildDetailRow('Order ID', payment.orderId),
                  _buildDetailRow('Amount',
                      '${payment.currency} ${payment.amount.toStringAsFixed(2)}'),
                  _buildDetailRow('Method', _getMethodName(payment.method)),
                  _buildDetailRow('Status', _getStatusText(payment.status)),
                  if (payment.transactionId != null)
                    _buildDetailRow('Transaction ID', payment.transactionId!),
                  _buildDetailRow('Date', _formatDateTime(payment.createdAt)),
                  if (payment.completedAt != null)
                    _buildDetailRow(
                        'Completed', _formatDateTime(payment.completedAt!)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          if (isSuccess) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to order tracking
                  context.push('/order-tracking/${payment.orderId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.go('/customer-home');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ] else if (isPending) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Refresh payment status
                  ref
                      .read(paymentProvider.notifier)
                      .getPaymentStatus(payment.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Check Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else if (isFailed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Retry payment
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.go('/customer-home');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Support Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Need Help?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contact our support team if you have any questions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // TODO: Implement contact support
                  },
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Colors.orange;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Icons.schedule;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Icons.error;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return Icons.refresh;
    }
  }

  String _getStatusTitle(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Payment Successful!';
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.processing:
        return 'Processing Payment';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
      case PaymentStatus.refunded:
        return 'Payment Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partial Refund';
    }
  }

  String _getStatusMessage(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Your payment has been processed successfully. Your order is being prepared.';
      case PaymentStatus.pending:
        return 'Your payment is pending confirmation. Please wait while we process your payment.';
      case PaymentStatus.processing:
        return 'Your payment is being processed. This may take a few moments.';
      case PaymentStatus.failed:
        return 'Your payment could not be processed. Please try again with a different method.';
      case PaymentStatus.cancelled:
        return 'Your payment was cancelled. You can try again or choose a different payment method.';
      case PaymentStatus.refunded:
        return 'Your payment has been fully refunded.';
      case PaymentStatus.partiallyRefunded:
        return 'A partial refund has been processed for your payment.';
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  String _getMethodName(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.cash:
        return 'Cash on Delivery';
      case PaymentMethodType.card:
        return 'Credit/Debit Card';
      case PaymentMethodType.wallet:
        return 'Digital Wallet';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
