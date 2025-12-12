import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import 'firebase_service.dart';

class ScheduleService {
  final FirebaseService _firebaseService = FirebaseService();

  // Check if shop is open based on schedule and current time
  bool isShopOpen(ShopSchedule schedule) {
    if (!schedule.isOpen) return false;
    return schedule.isWithinBusinessHours();
  }

  // Get formatted time string (HH:mm)
  String formatTime(String timeStr) {
    try {
      final time = DateFormat('HH:mm').parse(timeStr);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return timeStr;
    }
  }

  // Check if current time is past close time
  bool isPastCloseTime(ShopSchedule schedule) {
    final now = DateTime.now();
    final nowTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return nowTime.compareTo(schedule.closeTime) >= 0;
  }

  // Get minutes until shop opens
  int minutesUntilOpen(ShopSchedule schedule) {
    final now = DateTime.now();
    final openParts = schedule.openTime.split(':');
    final openHour = int.parse(openParts[0]);
    final openMinute = int.parse(openParts[1]);

    var openDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      openHour,
      openMinute,
    );

    if (openDateTime.isBefore(now)) {
      openDateTime = openDateTime.add(const Duration(days: 1));
    }

    return openDateTime.difference(now).inMinutes;
  }

  // Auto-deactivate menu if past close time (call this periodically from admin app)
  Future<void> checkAndAutoDeactivate() async {
    try {
      final scheduleStream = _firebaseService.streamSchedule();
      scheduleStream.first.then((schedule) {
        if (isPastCloseTime(schedule) && schedule.isOpen) {
          _firebaseService.updateSchedule(
            ShopSchedule(
              openTime: schedule.openTime,
              closeTime: schedule.closeTime,
              timezone: schedule.timezone,
              isOpen: false,
              updatedAt: DateTime.now(),
            ),
          );
          _firebaseService.clearActiveMenu();
        }
      });
    } catch (e) {
      debugPrint('Auto-deactivate error: $e');
    }
  }
}
