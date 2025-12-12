import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/firebase_service.dart';
import '../../providers/connection_provider.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({Key? key}) : super(key: key);

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders>
    with SingleTickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _acceptOrder(Order order) async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    final opId = 'accept_${order.id}';
    connectionProvider.addPendingOperation(opId);
    try {
      await _firebaseService.updateOrderStatus(order.id, 'accepted');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order accepted')));
      }
    } finally {
      connectionProvider.removePendingOperation(opId);
    }
  }

  Future<void> _completeOrder(Order order) async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    final opId = 'complete_${order.id}';
    connectionProvider.addPendingOperation(opId);
    try {
      await _firebaseService.updateOrderStatus(order.id, 'completed');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order completed')));
      }
    } finally {
      connectionProvider.removePendingOperation(opId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingOrdersList(
            firebaseService: _firebaseService,
            onAccept: _acceptOrder,
          ),
          _OrderHistory(
            firebaseService: _firebaseService,
            onComplete: _completeOrder,
          ),
        ],
      ),
    );
  }
}

class _PendingOrdersList extends StatelessWidget {
  final FirebaseService firebaseService;
  final Function(Order) onAccept;

  const _PendingOrdersList({
    required this.firebaseService,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    
    return StreamBuilder<List<Order>>(
      stream: firebaseService.streamPendingOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(child: Text('No pending orders'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (connectionProvider
                                .isPending('accept_${order.id}'))
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.orange.shade700),
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Block: ${order.blockDoor}'),
                    Text('Mobile: ${order.mobile}'),
                    const SizedBox(height: 8),
                    Text('Items: ${order.items.length}'),
                    for (final item in order.items.values)
                      Text('  • ${item.name} x${item.qty} @ ₹${item.price}'),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ₹${order.total}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onAccept(order),
                        child: const Text('Accept'),
                      ),
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

class _OrderHistory extends StatelessWidget {
  final FirebaseService firebaseService;
  final Function(Order) onComplete;

  const _OrderHistory({
    required this.firebaseService,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: firebaseService.streamAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders =
            (snapshot.data ?? []).where((o) => o.status != 'pending').toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (orders.isEmpty) {
          return const Center(child: Text('No completed orders'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(order.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Block: ${order.blockDoor}'),
                    Text('Total: ₹${order.total}'),
                  ],
                ),
                trailing: Chip(
                  label: Text(order.status),
                  backgroundColor: order.status == 'accepted'
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                ),
                onTap: () {
                  if (order.status == 'accepted') {
                    onComplete(order);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
