import 'package:flutter/material.dart';
import '../../models/schedule.dart';
import '../../services/firebase_service.dart';
import '../../services/schedule_service.dart';

class ScheduleEditor extends StatefulWidget {
  const ScheduleEditor({Key? key}) : super(key: key);

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  final _firebaseService = FirebaseService();
  final _scheduleService = ScheduleService();
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _timezoneController;
  bool _activating = false;

  @override
  void initState() {
    super.initState();
    _openTimeController = TextEditingController();
    _closeTimeController = TextEditingController();
    _timezoneController = TextEditingController(text: 'Asia/Kolkata');
  }

  @override
  void dispose() {
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    setState(() => _activating = true);
    try {
      final schedule = ShopSchedule(
        openTime: _openTimeController.text,
        closeTime: _closeTimeController.text,
        timezone: _timezoneController.text,
        isOpen: true,
        updatedAt: DateTime.now(),
      );

      // Update schedule
      await _firebaseService.updateSchedule(schedule);

      // Publish current menu from master (only enabled items)
      await _firebaseService.streamMenuMaster().first.then((items) async {
        final activeMenuMap = <String, Map<String, dynamic>>{};
        for (final item in items) {
          if (item.enabled) {
            activeMenuMap[item.id] = item.toMap();
          }
        }
        await _firebaseService.publishActiveMenu(activeMenuMap);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Shop activated!')));
      }
    } finally {
      setState(() => _activating = false);
    }
  }

  Future<void> _deactivateNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deactivate Now?'),
        content: const Text(
          'This will clear the active menu and close the shop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firebaseService.streamSchedule().first.then((schedule) async {
        final updatedSchedule = ShopSchedule(
          openTime: schedule.openTime,
          closeTime: schedule.closeTime,
          timezone: schedule.timezone,
          isOpen: false,
          updatedAt: DateTime.now(),
        );
        await _firebaseService.updateSchedule(updatedSchedule);
        await _firebaseService.clearActiveMenu();
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Shop deactivated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopSchedule>(
      stream: _firebaseService.streamSchedule(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final schedule = snapshot.data;
        if (schedule != null && _openTimeController.text.isEmpty) {
          _openTimeController.text = schedule.openTime;
          _closeTimeController.text = schedule.closeTime;
          _timezoneController.text = schedule.timezone;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shop Schedule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (schedule != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${schedule.isOpen ? "OPEN" : "CLOSED"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: schedule.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Opens: ${_scheduleService.formatTime(schedule.openTime)}',
                        ),
                        Text(
                          'Closes: ${_scheduleService.formatTime(schedule.closeTime)}',
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const Text('Configure Hours'),
              const SizedBox(height: 16),
              TextField(
                controller: _openTimeController,
                decoration: InputDecoration(
                  labelText: 'Opening Time',
                  hintText: 'HH:mm',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () => _pickTime(_openTimeController),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _closeTimeController,
                decoration: InputDecoration(
                  labelText: 'Closing Time',
                  hintText: 'HH:mm',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () => _pickTime(_closeTimeController),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _timezoneController,
                decoration: const InputDecoration(
                  labelText: 'Timezone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _activating ? null : _activate,
                  icon: _activating
                      ? const SizedBox()
                      : const Icon(Icons.check_circle),
                  label: _activating
                      ? const Text('Activating...')
                      : const Text('Activate Now'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deactivateNow,
                  icon: const Icon(Icons.close),
                  label: const Text('Deactivate Now'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
