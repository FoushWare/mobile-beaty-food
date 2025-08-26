import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_widget.dart';

class ChefOrderQueueScreen extends ConsumerStatefulWidget {
  const ChefOrderQueueScreen({super.key});

  @override
  ConsumerState<ChefOrderQueueScreen> createState() =>
      _ChefOrderQueueScreenState();
}

class _ChefOrderQueueScreenState extends ConsumerState<ChefOrderQueueScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedStatus = _getStatusFromIndex(_tabController.index);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).getChefOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return 'pending';
      case 1:
        return 'preparing';
      case 2:
        return 'ready';
      case 3:
        return 'completed';
      default:
        return 'pending';
    }
  }

  int _getIndexFromStatus(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'preparing':
        return 1;
      case 'ready':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Queue'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(orderProvider.notifier).getChefOrders();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Preparing'),
            Tab(text: 'Ready'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: orderState.isLoading
          ? const LoadingWidget(message: 'Loading orders...')
          : orderState.error != null
              ? _buildErrorWidget(orderState.error!)
              : _buildOrderList(orderState.orders),
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
            'Error loading orders',
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
              ref.read(orderProvider.notifier).getChefOrders();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    final filteredOrders = orders.where((order) {
      return order.status.toLowerCase() == _selectedStatus.toLowerCase();
    }).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(orderProvider.notifier).getChefOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedStatus) {
      case 'pending':
        message = 'No pending orders';
        icon = Icons.schedule;
        break;
      case 'preparing':
        message = 'No orders in preparation';
        icon = Icons.restaurant;
        break;
      case 'ready':
        message = 'No orders ready for pickup';
        icon = Icons.check_circle;
        break;
      case 'completed':
        message = 'No completed orders';
        icon = Icons.done_all;
        break;
      default:
        message = 'No orders found';
        icon = Icons.inbox;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/order-details/${order.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${order.items.length} items',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '• ${item.quantity}x ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Expanded(
                          child: Text(
                            item.recipeTitle,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 2)
                Text(
                  '... and ${order.items.length - 2} more items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Text(
                        '${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                      ),
                    ],
                  ),
                  if (_canUpdateStatus(order.status))
                    _buildActionButtons(order),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'preparing':
        color = Colors.blue;
        text = 'Preparing';
        break;
      case 'ready':
        color = Colors.green;
        text = 'Ready';
        break;
      case 'out_for_delivery':
        color = Colors.purple;
        text = 'Out for Delivery';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _canUpdateStatus(String currentStatus) {
    return ['pending', 'preparing', 'ready']
        .contains(currentStatus.toLowerCase());
  }

  Widget _buildActionButtons(Order order) {
    return Row(
      children: [
        if (order.status.toLowerCase() == 'pending')
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order.id, 'preparing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Start Preparing'),
          ),
        if (order.status.toLowerCase() == 'preparing')
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order.id, 'ready'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Mark Ready'),
          ),
        if (order.status.toLowerCase() == 'ready')
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order.id, 'out_for_delivery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Out for Delivery'),
          ),
      ],
    );
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content:
            Text('Are you sure you want to mark this order as "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(orderProvider.notifier).updateOrder(
                orderId,
                {'status': newStatus},
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
