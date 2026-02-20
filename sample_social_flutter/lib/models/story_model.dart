class UserStoriesModel {
  final String? storyUrl;
  final int storyAt;

  UserStoriesModel({this.storyUrl, required this.storyAt});

  factory UserStoriesModel.fromMap(Map<dynamic, dynamic> map) {
    return UserStoriesModel(
      storyUrl: map['storyUrl'],
      storyAt: (map['storyAt'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'storyUrl': storyUrl,
        'storyAt': storyAt,
      };
}

class StoryModel {
  final String? storyBy;
  final int storyAt;
  final List<UserStoriesModel> stories;

  StoryModel({
    this.storyBy,
    required this.storyAt,
    this.stories = const [],
  });
}
