import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerFeedbackScreen extends ConsumerWidget {
  const CustomerFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock feedback data
    final feedbackData = {
      'overallRating': 4.8,
      'totalReviews': 28,
      'ratingBreakdown': {
        5: 18,
        4: 7,
        3: 2,
        2: 1,
        1: 0,
      },
    };

    final reviews = [
      {
        'id': '1',
        'customerName': 'Ahmed Hassan',
        'rating': 5,
        'comment': 'Amazing food! The Koshari was perfect and delivery was on time.',
        'date': '2024-01-16',
        'recipeName': 'Koshari',
      },
      {
        'id': '2',
        'customerName': 'Fatima Ali',
        'rating': 4,
        'comment': 'Great taste, but delivery was a bit late. Still very satisfied!',
        'date': '2024-01-15',
        'recipeName': 'Ful Medames',
      },
      {
        'id': '3',
        'customerName': 'Mohammed Omar',
        'rating': 5,
        'comment': 'Best Egyptian food I\'ve had in a long time. Highly recommended!',
        'date': '2024-01-14',
        'recipeName': 'Molokhia',
      },
      {
        'id': '4',
        'customerName': 'Aisha Ahmed',
        'rating': 3,
        'comment': 'Food was good but portion size was smaller than expected.',
        'date': '2024-01-13',
        'recipeName': 'Mahshi',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback'),
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
            // Header
            Text(
              'Customer Reviews',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Overall Rating Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              '${feedbackData['overallRating']}',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                final rating = feedbackData['overallRating'] as double;
                                return Icon(
                                  index < rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Rating',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${feedbackData['totalReviews']} reviews',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                                                             // Rating breakdown
                               ...List.generate(5, (index) {
                                 final rating = 5 - index;
                                 final breakdown = feedbackData['ratingBreakdown'] as Map<int, int>;
                                 final count = breakdown[rating] ?? 0;
                                 final totalReviews = feedbackData['totalReviews'] as int;
                                 final percentage = totalReviews > 0
                                     ? (count / totalReviews) * 100
                                     : 0.0;
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$rating',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: percentage / 100,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        count.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reviews List
            Text(
              'Recent Reviews',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...reviews.map((review) => _buildReviewCard(review, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: Text(
                    review['customerName'][0],
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['customerName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        review['recipeName'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review['comment'],
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red[300],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Helpful',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.reply,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
