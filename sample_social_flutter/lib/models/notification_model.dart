class NotificationModel {
  final String? notificationId;
  final String? notifyBy;
  final String? notifyPostId;
  final String notifyType; // 'like', 'comment', 'follow'
  final int notifiedAt;

  NotificationModel({
    this.notificationId,
    this.notifyBy,
    this.notifyPostId,
    required this.notifyType,
    required this.notifiedAt,
  });

  factory NotificationModel.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    return NotificationModel(
      notificationId: id,
      notifyBy: map['notifyBy'],
      notifyPostId: map['notifyPostId'],
      notifyType: map['notifyType'] ?? 'like',
      notifiedAt: (map['notifiedAt'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'notifyBy': notifyBy,
        'notifyPostId': notifyPostId,
        'notifyType': notifyType,
        'notifiedAt': notifiedAt,
      };
}
