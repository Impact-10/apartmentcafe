import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/firebase_service.dart';

class MenuTabRedesign extends StatefulWidget {
  const MenuTabRedesign({super.key});

  @override
  State<MenuTabRedesign> createState() => _MenuTabRedesignState();
}

class _MenuTabRedesignState extends State<MenuTabRedesign> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Active Menu'),
                Tab(text: 'Master Menu'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ActiveMenuTab(),
                _MasterMenuTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Active Menu - Nested tabs by meal type
class _ActiveMenuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return StreamBuilder<Map<String, MenuItem>>(
      stream: service.streamMasterMenu(),
      builder: (context, masterSnapshot) {
        if (masterSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final masterMenu = masterSnapshot.data ?? {};
        if (masterMenu.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No items in master menu',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add items in Master Menu tab first',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Group by meal type and sort
        // Canonicalize meal names and group. Accept any labels (case/space tolerant).
        String canon(String raw) {
          final v = (raw.trim().toLowerCase());
          if (v == 'breakfast' || v == 'bf' || v == 'morning') return 'Breakfast';
          if (v == 'lunch' || v == 'noon') return 'Lunch';
          if (v == 'snack' || v == 'snacks' || v == 'evening' || v == 'eve') return 'Snack';
          if (v == 'dinner' || v == 'night') return 'Dinner';
          // Fall back to original (capitalized) label so it still shows up
          if (raw.isEmpty) return 'Other';
          return raw[0].toUpperCase() + raw.substring(1);
        }

        final mealOrder = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];
        final grouped = <String, List<MenuItem>>{};
        for (final item in masterMenu.values) {
          final key = canon(item.meal);
          grouped.putIfAbsent(key, () => []).add(item);
        }

        final sortedMeals = grouped.keys.toList()
          ..sort((a, b) {
            final ai = mealOrder.indexOf(a);
            final bi = mealOrder.indexOf(b);
            final ax = ai == -1 ? 999 : ai;
            final bx = bi == -1 ? 999 : bi;
            if (ax != bx) return ax.compareTo(bx);
            return a.compareTo(b);
          });

        if (sortedMeals.isEmpty) {
          return Center(
            child: Text(
              'No meals configured',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }

        return DefaultTabController(
          length: sortedMeals.length,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  isScrollable: true,
                  tabs: [
                    for (final meal in sortedMeals)
                      Tab(text: meal),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final meal in sortedMeals)
                      _MealTypeTab(
                        mealType: meal,
                        items: grouped[meal] ?? [],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
// Single meal type tab content
class _MealTypeTab extends StatelessWidget {
  final String mealType;
  final List<MenuItem> items;

  const _MealTypeTab({
    required this.mealType,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return StreamBuilder<Map<String, MenuItem>>(
      stream: service.streamActivemMenuMap(),
      builder: (context, activeSnapshot) {
        final activeMenu = activeSnapshot.data ?? {};

        if (items.isEmpty) {
          return Center(
            child: Text(
              'No items in $mealType',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isActive = activeMenu.containsKey(item.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${item.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (value) async {
                        if (value) {
                          await service.addToActiveMenu(item);
                        } else {
                          await service.removeFromActiveMenu(item.id);
                        }
                      },
                      activeTrackColor: const Color(0xFFFF6B35),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Master Menu - Add/Edit/Delete items
class _MasterMenuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return StreamBuilder<Map<String, MenuItem>>(
      stream: service.streamMasterMenu(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data?.values.toList() ?? [];

        final grouped = <String, List<MenuItem>>{};
        for (final item in items) {
          grouped.putIfAbsent(item.meal, () => []).add(item);
        }

        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No items in master menu',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final entry in grouped.entries) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                          for (final item in entry.value)
                            Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${item.price}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFFFF6B35),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFFFF6B35)),
                                      onPressed: () => _showEditDialog(context, service, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirm(context, service, item),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, service, null),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, FirebaseService service, MenuItem? item) {
    final nameController = TextEditingController(text: item?.name);
    final descController = TextEditingController(text: item?.description);
    final priceController = TextEditingController(
      text: item?.price.toStringAsFixed(0),
    );
    String selectedMeal = item?.meal ?? 'Breakfast';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedMeal,
                  decoration: const InputDecoration(
                    labelText: 'Meal Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Breakfast', 'Lunch', 'Snack', 'Dinner']
                      .map((meal) => DropdownMenuItem(
                            value: meal,
                            child: Text(meal),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMeal = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final price = int.tryParse(priceController.text) ?? 0;

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final newItem = MenuItem(
                id: item?.id ?? '',
                name: name,
                description: desc,
                price: price,
                meal: selectedMeal,
                enabled: item?.enabled ?? true,
                imageUrl: item?.imageUrl ?? 'https://via.placeholder.com/150',
              );

              if (item == null) {
                await service.addMasterMenuItem(newItem);
              } else {
                await service.updateMasterMenuItem(newItem);
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(item == null ? 'Item added' : 'Item updated')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: Text(item == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, FirebaseService service, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.deleteMasterMenuItem(item.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
