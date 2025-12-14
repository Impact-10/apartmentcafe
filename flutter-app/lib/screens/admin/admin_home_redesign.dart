import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'orders_tab_redesign.dart';
import 'menu_tab_redesign.dart';
import 'settings_tab_redesign.dart';

class AdminHomeRedesign extends StatefulWidget {
  const AdminHomeRedesign({super.key});

  @override
  State<AdminHomeRedesign> createState() => _AdminHomeRedesignState();
}

class _AdminHomeRedesignState extends State<AdminHomeRedesign> {
  int _currentIndex = 0;
  bool _isShopOpen = false;

  @override
  void initState() {
    super.initState();
    _listenToShopStatus();
  }

  void _listenToShopStatus() {
    FirebaseDatabase.instance
        .ref('shopSchedule/isOpen')
        .onValue
        .listen((event) {
      if (mounted && event.snapshot.value != null) {
        setState(() {
          _isShopOpen = event.snapshot.value as bool? ?? false;
        });
      }
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const OrdersTabRedesign(),
      const MenuTabRedesign(),
      const SettingsTabRedesign(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.restaurant,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Apartment Café',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Shop status chip
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isShopOpen
                  ? Colors.green[50]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isShopOpen
                    ? Colors.green[300]!
                    : Colors.grey[400]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isShopOpen ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isShopOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isShopOpen ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // More menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
