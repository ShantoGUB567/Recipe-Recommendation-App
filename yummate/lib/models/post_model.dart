class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String caption;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likedBy;
  final int likeCount;
  final int unlikeCount;
  final List<CommentModel> comments;
  final double averageRating;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.caption,
    this.imageUrl,
    required this.createdAt,
    this.likedBy = const [],
    this.likeCount = 0,
    this.unlikeCount = 0,
    this.comments = const [],
    this.averageRating = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'caption': caption,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
      'likeCount': likeCount,
      'unlikeCount': unlikeCount,
      'comments': comments.map((c) => c.toJson()).toList(),
      'averageRating': averageRating,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle likedBy which might be a Map or List
    List<String> parseLikedBy() {
      final likedByData = json['likedBy'];
      if (likedByData == null) return [];
      if (likedByData is List) return List<String>.from(likedByData);
      if (likedByData is Map) {
        return likedByData.keys.map((e) => e.toString()).toList();
      }
      return [];
    }

    return PostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userPhotoUrl: json['userPhotoUrl'],
      caption: json['caption'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      likedBy: parseLikedBy(),
      likeCount: json['likeCount'] ?? 0,
      unlikeCount: json['unlikeCount'] ?? 0,
      comments:
          (json['comments'] as List?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final double rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    this.rating = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userPhotoUrl: json['userPhotoUrl'],
      text: json['text'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
