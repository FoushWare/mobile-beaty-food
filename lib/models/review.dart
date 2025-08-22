class Review {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String targetId; // Recipe ID or Chef ID
  final ReviewType type;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage = '',
    required this.targetId,
    required this.type,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'] ?? '',
      targetId: json['targetId'] ?? '',
      type: ReviewType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReviewType.recipe,
      ),
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'targetId': targetId,
      'type': type.name,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }
}

enum ReviewType { recipe, chef }