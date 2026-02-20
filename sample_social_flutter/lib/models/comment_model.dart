class CommentModel {
  final String? commentId;
  final String? commenter;
  final String commentText;
  final int commentedAt;

  CommentModel({
    this.commentId,
    this.commenter,
    required this.commentText,
    required this.commentedAt,
  });

  factory CommentModel.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    return CommentModel(
      commentId: id,
      commenter: map['commenter'],
      commentText: map['commentText'] ?? '',
      commentedAt: (map['commentedAt'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'commenter': commenter,
        'commentText': commentText,
        'commentedAt': commentedAt,
      };
}
