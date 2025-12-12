import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../providers/connection_provider.dart';
import 'master_item_editor.dart';
import 'section_editor.dart';
import 'schedule_editor.dart';
import 'admin_orders.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _firebaseService = FirebaseService();
  int _selectedIndex = 0;

  void _signOut() {
    _firebaseService.signOut();
    Navigator.of(context).pop();
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Master Menu'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MasterItemEditor()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              _signOut();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.getCurrentUser();
    final connectionProvider = Provider.of<ConnectionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showMenu),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!connectionProvider.isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.shade700,
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline — Changes will sync when online',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          // Pending operations indicator
          if (connectionProvider.pendingOperations.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${connectionProvider.pendingOperations.length} pending sync',
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Logged in as: ${user?.email}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                SectionEditor(),
                ScheduleEditor(),
                AdminOrders(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
