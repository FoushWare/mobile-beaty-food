import 'package:flutter/material.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/models/order.dart';
import 'package:baty_bites/models/address.dart';
import 'package:baty_bites/models/recipe.dart';

class OrderQueueScreen extends StatefulWidget {
  const OrderQueueScreen({super.key});

  @override
  State<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends State<OrderQueueScreen> {
  String _selectedFilter = 'all';
  final List<Order> _orders = _getMockOrders();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('طوابير الطلبات'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Summary Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Summary
                Row(
                  children: [
                    _buildStatusSummary('الكل', _orders.length, Colors.blue),
                    _buildStatusSummary(
                        'جديد',
                        _orders
                            .where((o) => o.status == OrderStatus.pending)
                            .length,
                        Colors.orange),
                    _buildStatusSummary(
                        'قيد التحضير',
                        _orders
                            .where((o) => o.status == OrderStatus.preparing)
                            .length,
                        Colors.purple),
                    _buildStatusSummary(
                        'جاهز',
                        _orders
                            .where((o) => o.status == OrderStatus.ready)
                            .length,
                        Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'الكل', _orders.length),
                      _buildFilterChip(
                          'pending',
                          'جديد',
                          _orders
                              .where((o) => o.status == OrderStatus.pending)
                              .length),
                      _buildFilterChip(
                          'confirmed',
                          'مؤكد',
                          _orders
                              .where((o) => o.status == OrderStatus.confirmed)
                              .length),
                      _buildFilterChip(
                          'preparing',
                          'قيد التحضير',
                          _orders
                              .where((o) => o.status == OrderStatus.preparing)
                              .length),
                      _buildFilterChip(
                          'ready',
                          'جاهز',
                          _orders
                              .where((o) => o.status == OrderStatus.ready)
                              .length),
                      _buildFilterChip(
                          'ready',
                          'جاهز للتوصيل',
                          _orders
                              .where((o) => o.status == OrderStatus.ready)
                              .length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final timeAgo = _getTimeAgo(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const Spacer(),
                Text(
                  'طلب #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Customer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العميل',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Recipe Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: order.items.isNotEmpty &&
                            order.items.first.recipe.images.isNotEmpty
                        ? Image.network(
                            order.items.first.recipe.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.restaurant,
                                  size: 25, color: Colors.grey);
                            },
                          )
                        : const Icon(Icons.restaurant,
                            size: 25, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.items.isNotEmpty
                            ? order.items.first.recipe.title
                            : 'وصفة',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        'الكمية: ${order.items.isNotEmpty ? order.items.first.quantity : 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(0)} جنيه',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Delivery Address
            if (order.deliveryAddress.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                if (order.status == OrderStatus.pending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order, OrderStatus.confirmed),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('قبول'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order, OrderStatus.cancelled),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('رفض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
                if (order.status == OrderStatus.confirmed) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order, OrderStatus.preparing),
                      icon: const Icon(Icons.restaurant, size: 16),
                      label: const Text('بدء التحضير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
                if (order.status == OrderStatus.preparing) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order, OrderStatus.ready),
                      icon: const Icon(Icons.done, size: 16),
                      label: const Text('جاهز للتوصيل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
                if (order.status == OrderStatus.ready) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order, OrderStatus.ready),
                      icon: const Icon(Icons.delivery_dining, size: 16),
                      label: const Text('في الطريق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
                if (order.status == OrderStatus.ready) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order, OrderStatus.delivered),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('تم التوصيل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showOrderDetails(order),
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'تفاصيل الطلب',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الطلبات الجديدة هنا',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  List<Order> _getFilteredOrders() {
    List<Order> filtered = _orders;

    // Apply status filter
    switch (_selectedFilter) {
      case 'pending':
        filtered = filtered
            .where((order) => order.status == OrderStatus.pending)
            .toList();
        break;
      case 'confirmed':
        filtered = filtered
            .where((order) => order.status == OrderStatus.confirmed)
            .toList();
        break;
      case 'preparing':
        filtered = filtered
            .where((order) => order.status == OrderStatus.preparing)
            .toList();
        break;
      case 'ready':
        filtered = filtered
            .where((order) => order.status == OrderStatus.ready)
            .toList();
        break;
      case 'ready':
        filtered = filtered
            .where((order) => order.status == OrderStatus.ready)
            .toList();
        break;
    }

    // Sort by creation time (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
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
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  void _updateOrderStatus(Order order, OrderStatus newStatus) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        // In a real app, this would call an API
        // For now, we'll just show a snackbar
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث حالة الطلب إلى: ${_getStatusText(newStatus)}',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار الموافقة';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز للتوصيل';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'تفاصيل الطلب #${order.id.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow('العميل', 'العميل'),
                    _buildDetailRow(
                        'الوصفة',
                        order.items.isNotEmpty
                            ? order.items.first.recipe.title
                            : 'وصفة'),
                    _buildDetailRow(
                        'الكمية',
                        order.items.isNotEmpty
                            ? order.items.first.quantity.toString()
                            : '0'),
                    _buildDetailRow('السعر الإجمالي',
                        '${order.total.toStringAsFixed(0)} جنيه'),
                    _buildDetailRow(
                        'طريقة الدفع', order.paymentMethod ?? 'غير محدد'),
                    _buildDetailRow('الحالة', order.statusText),
                    if (order.deliveryInstructions != null &&
                        order.deliveryInstructions!.isNotEmpty)
                      _buildDetailRow(
                          'ملاحظات التوصيل', order.deliveryInstructions!),
                    const SizedBox(height: 16),
                    const Text(
                      'عنوان التوصيل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.deliveryAddress ?? 'عنوان غير محدد',
                        style: const TextStyle(fontSize: 14),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshOrders() {
    // In a real app, this would fetch orders from the API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تحديث الطلبات',
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  static List<Order> _getMockOrders() {
    // Create sample recipes for the mock orders
    final sampleRecipe1 = Recipe(
      id: 'recipe_1',
      title: 'كبسة الدجاج',
      description: 'كبسة دجاج تقليدية',
      price: 45.0,
      chefId: 'chef_1',
      chefName: 'الشيف سارة',
      chefImage: 'https://example.com/chef1.jpg',
      images: ['https://example.com/kabsa.jpg'],
      ingredients: [],
      instructions: [],
      cuisineType: 'سعودي',
      category: 'وجبات رئيسية',
      preparationTime: 30,
      cookingTime: 45,
      servings: 4,
      difficulty: DifficultyLevel.medium,
      spiceLevel: SpiceLevel.medium,
      dietaryInfo: DietaryInfo(),
      tags: ['دجاج', 'أرز'],
      rating: 4.5,
      totalReviews: 120,
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sampleRecipe2 = Recipe(
      id: 'recipe_2',
      title: 'معجنات بالسبانخ',
      description: 'معجنات طازجة بالسبانخ',
      price: 25.0,
      chefId: 'chef_1',
      chefName: 'الشيف سارة',
      chefImage: 'https://example.com/chef1.jpg',
      images: ['https://example.com/spinach.jpg'],
      ingredients: [],
      instructions: [],
      cuisineType: 'إيطالي',
      category: 'معجنات',
      preparationTime: 20,
      cookingTime: 25,
      servings: 2,
      difficulty: DifficultyLevel.easy,
      spiceLevel: SpiceLevel.mild,
      dietaryInfo: DietaryInfo(),
      tags: ['معجنات', 'سبانخ'],
      rating: 4.2,
      totalReviews: 85,
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return [
      Order(
        id: 'order_001',
        customerId: 'customer_1',
        chefId: 'chef_1',
        items: [
          OrderItem(
            id: 'item_001',
            recipe: sampleRecipe1,
            quantity: 2,
            price: 45.0,
            specialInstructions: 'بدون بصل',
          ),
        ],
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        subtotal: 90.0,
        tax: 13.5,
        deliveryFee: 10.0,
        total: 113.5,
        deliveryAddress: 'شارع الجامعة 123، مدينة نصر، القاهرة',
        deliveryInstructions: 'الاتصال عند الوصول',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        paymentMethod: 'cash',
      ),
      Order(
        id: 'order_002',
        customerId: 'customer_2',
        chefId: 'chef_1',
        items: [
          OrderItem(
            id: 'item_002',
            recipe: sampleRecipe2,
            quantity: 1,
            price: 25.0,
          ),
        ],
        status: OrderStatus.confirmed,
        paymentStatus: PaymentStatus.paid,
        subtotal: 25.0,
        tax: 3.75,
        deliveryFee: 10.0,
        total: 38.75,
        deliveryAddress: 'شارع الدقي 456، الدقي، الجيزة',
        deliveryInstructions: '',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        paymentMethod: 'card',
      ),
      Order(
        id: 'order_003',
        customerId: 'customer_3',
        chefId: 'chef_1',
        items: [
          OrderItem(
            id: 'item_003',
            recipe: sampleRecipe1,
            quantity: 1,
            price: 45.0,
            specialInstructions: 'مطبوخ جيداً',
          ),
        ],
        status: OrderStatus.ready,
        paymentStatus: PaymentStatus.paid,
        subtotal: 45.0,
        tax: 6.75,
        deliveryFee: 10.0,
        total: 61.75,
        deliveryAddress: 'شارع الهرم 789، الهرم، الجيزة',
        deliveryInstructions: 'الطابق الثالث شقة 5',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        paymentMethod: 'wallet',
      ),
      Order(
        id: 'order_004',
        customerId: 'customer_4',
        chefId: 'chef_1',
        items: [
          OrderItem(
            id: 'item_004',
            recipe: sampleRecipe1,
            quantity: 3,
            price: 45.0,
          ),
        ],
        status: OrderStatus.confirmed,
        paymentStatus: PaymentStatus.pending,
        subtotal: 135.0,
        tax: 20.25,
        deliveryFee: 15.0,
        total: 170.25,
        deliveryAddress: 'شارع المعادي 321، المعادي، القاهرة',
        deliveryInstructions: 'مبنى أزرق بجوار الصيدلية',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        paymentMethod: 'cash',
      ),
      Order(
        id: 'order_005',
        customerId: 'customer_5',
        chefId: 'chef_1',
        items: [
          OrderItem(
            id: 'item_005',
            recipe: sampleRecipe2,
            quantity: 2,
            price: 25.0,
          ),
        ],
        status: OrderStatus.ready,
        paymentStatus: PaymentStatus.paid,
        subtotal: 50.0,
        tax: 7.5,
        deliveryFee: 10.0,
        total: 67.5,
        deliveryAddress: 'شارع التحرير 654، وسط البلد، القاهرة',
        deliveryInstructions: '',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        paymentMethod: 'card',
      ),
    ];
  }
}
