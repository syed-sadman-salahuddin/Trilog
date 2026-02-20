class PostModel {
  final String? postId;
  final String? postImage;
  final String? postedBy;
  final String postDescription;
  final int postedAt;
  final int postLike;
  final int commentCount;

  PostModel({
    this.postId,
    this.postImage,
    this.postedBy,
    required this.postDescription,
    required this.postedAt,
    this.postLike = 0,
    this.commentCount = 0,
  });

  factory PostModel.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    return PostModel(
      postId: id,
      postImage: map['postImage'],
      postedBy: map['postedBy'],
      postDescription: map['postDescription'] ?? '',
      postedAt: (map['postedAt'] ?? 0) as int,
      postLike: (map['postLike'] ?? 0) as int,
      commentCount: (map['commentCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'postImage': postImage,
        'postedBy': postedBy,
        'postDescription': postDescription,
        'postedAt': postedAt,
        'postLike': postLike,
        'commentCount': commentCount,
      };

  PostModel copyWith({
    String? postId,
    String? postImage,
    String? postedBy,
    String? postDescription,
    int? postedAt,
    int? postLike,
    int? commentCount,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      postImage: postImage ?? this.postImage,
      postedBy: postedBy ?? this.postedBy,
      postDescription: postDescription ?? this.postDescription,
      postedAt: postedAt ?? this.postedAt,
      postLike: postLike ?? this.postLike,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
