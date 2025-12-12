import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../services/firebase_service.dart';
import '../../providers/connection_provider.dart';

class SectionEditor extends StatefulWidget {
  const SectionEditor({super.key});

  @override
  State<SectionEditor> createState() => _SectionEditorState();
}

class _SectionEditorState extends State<SectionEditor> {
  final _firebaseService = FirebaseService();
  final Map<String, bool> _selectedItems = {};
  String _selectedMeal = 'breakfast';
  bool _publishing = false;

  Future<void> _publishActiveMenu() async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No items selected')));
      return;
    }

    // Warn if offline
    if (!connectionProvider.isConnected) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Offline'),
          content: const Text(
            'You are offline. Changes will be queued and synced when you reconnect. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    if (!mounted) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Publish Menu?'),
        content: const Text(
          'This will replace the current Active Menu. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _publishing = true);
    const opId = 'publish_menu';
    connectionProvider.addPendingOperation(opId);

    try {
      // Get all selected items from all meals
      final allSelected = <String, Map<String, dynamic>>{};

      await _firebaseService.streamMenuMaster().first.then((items) {
        for (final item in items) {
          if (_selectedItems[item.id] == true) {
            allSelected[item.id] = item.toMap();
          }
        }
      });

      // Publish as single set operation (full replace, no duplicates)
      await _firebaseService.publishActiveMenu(allSelected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menu published with ${allSelected.length} items'),
          ),
        );
      }
    } finally {
      connectionProvider.removePendingOperation(opId);
      setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish Menu by Section')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['breakfast', 'lunch', 'snack', 'dinner']
                    .map(
                      (meal) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(meal.toUpperCase()),
                          selected: _selectedMeal == meal,
                          onSelected: (_) =>
                              setState(() => _selectedMeal = meal),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: _firebaseService.streamMenuMaster(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = (snapshot.data ?? [])
                    .where((item) => item.meal == _selectedMeal)
                    .toList();

                if (items.isEmpty) {
                  return Center(child: Text('No items for $_selectedMeal'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = _selectedItems[item.id] ?? false;

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) {
                        setState(() {
                          _selectedItems[item.id] = !isSelected;
                        });
                      },
                      title: Text(item.name),
                      subtitle: Text('₹${item.price} • ${item.description}'),
                      secondary: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _publishing ? null : _publishActiveMenu,
        label: _publishing ? const SizedBox() : const Text('Publish'),
        icon: _publishing
            ? const CircularProgressIndicator()
            : const Icon(Icons.publish),
      ),
    );
  }
}
