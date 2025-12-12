import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/schedule.dart';
import '../../providers/cart_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/schedule_service.dart';
import 'cart.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key}) : super(key: key);

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final _firebaseService = FirebaseService();
  final _scheduleService = ScheduleService();
  String _selectedMeal = 'breakfast';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartment Café'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) => Text(
                  '${cart.itemCount} items',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<ShopSchedule>(
        stream: _firebaseService.streamSchedule(),
        builder: (context, scheduleSnapshot) {
          if (scheduleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final schedule = scheduleSnapshot.data;
          final isOpen =
              schedule != null && _scheduleService.isShopOpen(schedule);

          if (!isOpen) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Shop is Closed'),
                  const SizedBox(height: 8),
                  if (schedule != null)
                    Text(
                      'Opens at ${_scheduleService.formatTime(schedule.openTime)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['breakfast', 'lunch', 'snack', 'dinner']
                        .map(
                          (meal) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
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
                  stream: _firebaseService.streamActiveMenu(),
                  builder: (context, menuSnapshot) {
                    if (menuSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = (menuSnapshot.data ?? [])
                        .where((item) => item.meal == _selectedMeal)
                        .toList();

                    if (items.isEmpty) {
                      return Center(child: Text('No items for $_selectedMeal'));
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description),
                                Text(
                                  '₹${item.price}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () {
                                context.read<CartProvider>().addItem(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} added to cart'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Add'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) => cart.itemCount > 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text('Cart (${cart.itemCount})'),
              )
            : const SizedBox(),
      ),
    );
  }
}
