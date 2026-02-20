class UserModel {
  final String? userId;
  final String name;
  final String profession;
  final String email;
  final String? profile;
  final String? coverPhoto;
  final int followerCount;

  UserModel({
    this.userId,
    required this.name,
    required this.profession,
    required this.email,
    this.profile,
    this.coverPhoto,
    this.followerCount = 0,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    return UserModel(
      userId: id,
      name: map['name'] ?? '',
      profession: map['profession'] ?? '',
      email: map['email'] ?? '',
      profile: map['profile'],
      coverPhoto: map['coverPhoto'],
      followerCount: (map['followerCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'profession': profession,
        'email': email,
        'profile': profile,
        'coverPhoto': coverPhoto,
        'followerCount': followerCount,
      };

  UserModel copyWith({
    String? userId,
    String? name,
    String? profession,
    String? email,
    String? profile,
    String? coverPhoto,
    int? followerCount,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      followerCount: followerCount ?? this.followerCount,
    );
  }
}
