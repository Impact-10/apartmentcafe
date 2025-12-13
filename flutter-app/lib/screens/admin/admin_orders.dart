import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/firebase_service.dart';
import '../../providers/connection_provider.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

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
    _tabController = TabController(length: 3, vsync: this);
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

  Future<void> _deliverOrder(Order order) async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    final opId = 'deliver_${order.id}';
    connectionProvider.addPendingOperation(opId);
    try {
      await _firebaseService.updateOrderStatus(order.id, 'delivered');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order marked as delivered')));
      }
    } finally {
      connectionProvider.removePendingOperation(opId);
    }
  }

  Future<void> _archiveOrder(Order order) async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    final opId = 'archive_${order.id}';
    connectionProvider.addPendingOperation(opId);
    try {
      await _firebaseService.archiveOrder(order);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order archived')));
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
            Tab(text: 'Accepted'),
            Tab(text: 'Delivered'),
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
          _AcceptedOrdersList(
            firebaseService: _firebaseService,
            onDeliver: _deliverOrder,
          ),
          _DeliveredOrdersList(
            firebaseService: _firebaseService,
            onArchive: _archiveOrder,
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

class _AcceptedOrdersList extends StatelessWidget {
  final FirebaseService firebaseService;
  final Function(Order) onDeliver;

  const _AcceptedOrdersList({
    required this.firebaseService,
    required this.onDeliver,
  });

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    
    return StreamBuilder<List<Order>>(
      stream: firebaseService.streamAcceptedOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (orders.isEmpty) {
          return const Center(child: Text('No accepted orders'));
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
                                .isPending('deliver_${order.id}'))
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
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Accepted',
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
                        onPressed: () => onDeliver(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Mark Delivered'),
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

class _DeliveredOrdersList extends StatelessWidget {
  final FirebaseService firebaseService;
  final Function(Order) onArchive;

  const _DeliveredOrdersList({
    required this.firebaseService,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: firebaseService.streamDeliveredOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (orders.isEmpty) {
          return const Center(child: Text('No delivered orders'));
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
                    if (order.deliveredAt != null)
                      Text(
                        'Delivered: ${order.deliveredAt!.toString().split('.')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Delivered',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Show confirmation dialog before archiving
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Archive Order?'),
                      content: const Text(
                        'This will move the order to history. Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onArchive(order);
                          },
                          child: const Text('Archive'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
