class ShopSchedule {
  final String openTime; // HH:mm format
  final String closeTime; // HH:mm format
  final String timezone;
  final bool isOpen;
  final DateTime updatedAt;

  ShopSchedule({
    required this.openTime,
    required this.closeTime,
    required this.timezone,
    required this.isOpen,
    required this.updatedAt,
  });

  factory ShopSchedule.fromMap(Map<dynamic, dynamic> data) {
    return ShopSchedule(
      openTime: data['openTime'] ?? '07:00',
      closeTime: data['closeTime'] ?? '21:00',
      timezone: data['timezone'] ?? 'Asia/Kolkata',
      isOpen: data['isOpen'] ?? false,
      updatedAt: data['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'openTime': openTime,
      'closeTime': closeTime,
      'timezone': timezone,
      'isOpen': isOpen,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  bool isWithinBusinessHours() {
    final now = DateTime.now();
    final nowTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return nowTime.compareTo(openTime) >= 0 && nowTime.compareTo(closeTime) < 0;
  }
}
