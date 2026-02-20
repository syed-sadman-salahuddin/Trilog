class FollowModel {
  final String? followingId;

  FollowModel({this.followingId});

  factory FollowModel.fromMap(Map<dynamic, dynamic> map) {
    return FollowModel(followingId: map['followingId']);
  }

  Map<String, dynamic> toMap() => {'followingId': followingId};
}
