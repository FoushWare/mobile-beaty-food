import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/recipe.dart';

class RecipeAnalyticsScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeAnalyticsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock analytics data for the recipe
    final analyticsData = {
      'totalOrders': recipe.orderCount,
      'totalRevenue': recipe.orderCount * recipe.price,
      'avgRating': recipe.rating,
      'totalReviews': recipe.totalReviews,
      'completionRate': 95.0,
      'avgPrepTime': recipe.preparationTime + recipe.cookingTime,
      'popularityScore': 8.5,
      'profitMargin': 65.0,
    };

    final monthlyData = [
      {'month': 'Jan', 'orders': 12, 'revenue': 540.0},
      {'month': 'Feb', 'orders': 18, 'revenue': 810.0},
      {'month': 'Mar', 'orders': 15, 'revenue': 675.0},
      {'month': 'Apr', 'orders': 22, 'revenue': 990.0},
      {'month': 'May', 'orders': 25, 'revenue': 1125.0},
      {'month': 'Jun', 'orders': 30, 'revenue': 1350.0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${recipe.title} Analytics'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: recipe.images.isNotEmpty
                            ? Image.network(
                                recipe.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.restaurant,
                                      size: 40, color: Colors.grey);
                                },
                              )
                            : const Icon(Icons.restaurant,
                                size: 40, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(
                                ' ${recipe.rating.toStringAsFixed(1)} (${recipe.totalReviews} reviews)',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Spacer(),
                              Text(
                                'EGP ${recipe.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics
            Text(
              'Key Metrics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildMetricCard(
                  'Total Orders',
                  analyticsData['totalOrders']!.toString(),
                  Icons.shopping_bag,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Total Revenue',
                  'EGP ${analyticsData['totalRevenue']!.toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Avg Rating',
                  analyticsData['avgRating']!.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
                _buildMetricCard(
                  'Completion Rate',
                  '${analyticsData['completionRate']!.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Insights
            Text(
              'Performance Insights',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInsightItem(
                      'Popularity Score',
                      '${analyticsData['popularityScore']}/10',
                      'High demand recipe',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildInsightItem(
                      'Profit Margin',
                      '${analyticsData['profitMargin']!.toStringAsFixed(1)}%',
                      'Excellent profitability',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    _buildInsightItem(
                      'Avg Prep Time',
                      '${analyticsData['avgPrepTime']} min',
                      'Efficient preparation',
                      Icons.timer,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Trends
            Text(
              'Monthly Trends',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Mock chart placeholder
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Monthly Orders & Revenue',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coming Soon',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Monthly data table
                    const Text(
                      'Monthly Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...monthlyData.map((data) => _buildMonthlyDataRow(data)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Customer Feedback Summary
            Text(
              'Customer Feedback',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          recipe.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${recipe.totalReviews} reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rating breakdown
                    Row(
                      children: List.generate(5, (index) {
                        final rating = 5 - index;
                        final percentage = _getRatingPercentage(
                            rating, recipe.rating, recipe.totalReviews);

                        return Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$rating',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 60,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.bottomCenter,
                                  heightFactor: percentage / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations
            Text(
              'Recommendations',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRecommendationItem(
                      'Consider increasing price by 10%',
                      'High demand suggests room for price optimization',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildRecommendationItem(
                      'Add more photos',
                      'Visual appeal increases order conversion',
                      Icons.photo_camera,
                      Colors.blue,
                    ),
                    _buildRecommendationItem(
                      'Promote during peak hours',
                      'Schedule promotions during high-demand periods',
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, String description,
      IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyDataRow(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data['month'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '${data['orders']} orders',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'EGP ${data['revenue'].toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getRatingPercentage(int rating, double avgRating, int totalReviews) {
    // Mock calculation - in real app, this would come from actual review data
    if (totalReviews == 0) return 0.0;

    // Simple mock distribution based on average rating
    if (rating == avgRating.floor()) {
      return 40.0;
    } else if (rating == avgRating.floor() + 1) {
      return 30.0;
    } else if (rating == avgRating.floor() - 1) {
      return 20.0;
    } else if (rating > avgRating.floor() + 1) {
      return 10.0;
    } else {
      return 5.0;
    }
  }
}
