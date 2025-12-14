import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/firebase_service.dart';
import '../../providers/connection_provider.dart';

class OrdersTabRedesign extends StatelessWidget {
  const OrdersTabRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Delivered'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _OrdersList(status: 'pending'),
                _OrdersList(status: 'accepted'),
                _OrdersList(status: 'delivered'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final String status;

  const _OrdersList({required this.status});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    Stream<List<Order>> stream;

    switch (status) {
      case 'pending':
        stream = service.streamPendingOrders();
        break;
      case 'accepted':
        stream = service.streamAcceptedOrders();
        break;
      case 'delivered':
        stream = service.streamDeliveredOrders();
        break;
      default:
        stream = const Stream.empty();
    }

    return StreamBuilder<List<Order>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _EmptyState(status: status);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(order: order, status: status);
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String status;

  const _OrderCard({required this.order, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF6B35);
      case 'accepted':
        return const Color(0xFFFFA726);
      case 'delivered':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    final service = FirebaseService();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer name
            Text(
              order.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 6),

            // Block & door
            Row(
              children: [
                const Icon(Icons.apartment, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  order.blockDoor,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  order.mobile,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Items list
            ...order.items.values.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${item.qty}x',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '₹${(item.price * item.qty).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),

            // Action buttons
            if (status == 'pending' || status == 'accepted') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: connectionProvider.hasPendingOperations
                      ? null
                      : () async {
                          final opId =
                              '${status == 'pending' ? 'accept' : 'deliver'}_${order.id}';
                          connectionProvider.addPendingOperation(opId);

                          try {
                            if (status == 'pending') {
                              await service.updateOrderStatus(order.id, 'accepted');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order accepted'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } else if (status == 'accepted') {
                              await service.updateOrderStatus(order.id, 'delivered');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order marked as delivered'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          } finally {
                            connectionProvider.removePendingOperation(opId);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'pending'
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    status == 'pending' ? 'Accept Order' : 'Mark Delivered',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String status;

  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String message;

    switch (status) {
      case 'pending':
        icon = Icons.inbox_outlined;
        message = 'No pending orders';
        break;
      case 'accepted':
        icon = Icons.check_circle_outline;
        message = 'No accepted orders';
        break;
      case 'delivered':
        icon = Icons.done_all;
        message = 'No delivered orders yet';
        break;
      default:
        icon = Icons.inbox;
        message = 'No orders';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
