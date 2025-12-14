import 'package:flutter/material.dart';
import '../../models/schedule.dart';
import '../../services/firebase_service.dart';

class SettingsTabRedesign extends StatelessWidget {
  const SettingsTabRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ShopTimingCard(),
        const SizedBox(height: 16),
        _AccountCard(),
      ],
    );
  }
}

class _ShopTimingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return StreamBuilder<ShopSchedule>(
      stream: service.streamSchedule(),
      builder: (context, snapshot) {
        final schedule = snapshot.data ??
            ShopSchedule(
              openTime: '07:00',
              closeTime: '21:00',
              timezone: 'Asia/Kolkata',
              isOpen: false,
              updatedAt: DateTime.now(),
            );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Shop Timing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Open time
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.wb_sunny, color: Colors.green[700]),
                  ),
                  title: const Text('Opening Time'),
                  subtitle: Text(
                    _formatTime(schedule.openTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showTimePicker(
                      context,
                      'Opening Time',
                      schedule.openTime,
                      (time) async {
                        final updated = ShopSchedule(
                          openTime: time,
                          closeTime: schedule.closeTime,
                          timezone: schedule.timezone,
                          isOpen: schedule.isOpen,
                          updatedAt: DateTime.now(),
                        );
                        await service.updateSchedule(updated);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Close time
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.nightlight, color: Colors.orange[700]),
                  ),
                  title: const Text('Closing Time'),
                  subtitle: Text(
                    _formatTime(schedule.closeTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showTimePicker(
                      context,
                      'Closing Time',
                      schedule.closeTime,
                      (time) async {
                        final updated = ShopSchedule(
                          openTime: schedule.openTime,
                          closeTime: time,
                          timezone: schedule.timezone,
                          isOpen: schedule.isOpen,
                          updatedAt: DateTime.now(),
                        );
                        await service.updateSchedule(updated);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Current status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: schedule.isOpen
                        ? Colors.green[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: schedule.isOpen
                          ? Colors.green[200]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: schedule.isOpen ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        schedule.isOpen ? 'Shop is Open' : 'Shop is Closed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: schedule.isOpen
                              ? Colors.green[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Open/Close shop button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => schedule.isOpen
                        ? _confirmCloseShop(context, schedule)
                        : _confirmOpenShop(context, schedule),
                    icon: Icon(schedule.isOpen
                        ? Icons.store_mall_directory_outlined
                        : Icons.store),
                    label: Text(schedule.isOpen ? 'Close Shop Now' : 'Open Shop Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: schedule.isOpen ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  void _showTimePicker(
    BuildContext context,
    String title,
    String currentTime,
    Function(String) onSave,
  ) async {
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await onSave(formattedTime);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title updated to ${_formatTime(formattedTime)}')),
        );
      }
    }
  }

  void _confirmOpenShop(BuildContext context, ShopSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Shop'),
        content: const Text(
          'Open the shop for customers?\n\nRemember to:\n• Set today\'s active menu in Menu tab\n• Ensure timings are correct',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = FirebaseService();
              final updated = ShopSchedule(
                openTime: schedule.openTime,
                closeTime: schedule.closeTime,
                timezone: schedule.timezone,
                isOpen: true,
                updatedAt: DateTime.now(),
              );
              await service.updateSchedule(updated);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shop is now open!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Shop'),
          ),
        ],
      ),
    );
  }

  void _confirmCloseShop(BuildContext context, ShopSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Shop'),
        content: const Text(
          'This will:\n• Mark shop as closed\n• Stop accepting new orders\n\nNote: Active menu items will remain for next opening.\n\nContinue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = FirebaseService();
              final updated = ShopSchedule(
                openTime: schedule.openTime,
                closeTime: schedule.closeTime,
                timezone: schedule.timezone,
                isOpen: false,
                updatedAt: DateTime.now(),
              );
              await service.updateSchedule(updated);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shop is now closed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close Shop'),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text('App Version'),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.help_outline),
              title: Text('Support'),
              subtitle: Text('Contact: admin@apartmentcafe.com'),
            ),
          ],
        ),
      ),
    );
  }
}
