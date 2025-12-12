import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart' as order_model;
import '../../providers/cart_provider.dart';
import '../../services/firebase_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _blockController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _placing = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _blockController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_nameController.text.isEmpty ||
        _blockController.text.isEmpty ||
        _mobileController.text.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }

    if (_mobileController.text.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(_mobileController.text)) {
      setState(() => _error = 'Mobile must be 10 digits');
      return;
    }

    setState(() {
      _placing = true;
      _error = null;
    });

    try {
      final cart = context.read<CartProvider>();
      final items = <String, order_model.CartItem>{};

      for (final item in cart.items.values) {
        items[item.id] = order_model.CartItem(
          id: item.id,
          name: item.name,
          qty: item.qty,
          price: item.price,
        );
      }

      final order = order_model.Order(
        id: '', // Will be set by Firebase
        name: _nameController.text,
        blockDoor: _blockController.text,
        mobile: _mobileController.text,
        items: items,
        total: cart.totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final orderId = await _firebaseService.placeOrder(order);

      if (mounted) {
        cart.clear();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Order Placed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your order has been placed successfully.'),
                const SizedBox(height: 16),
                Text('Order ID: $orderId'),
                const SizedBox(height: 8),
                const Text('Status: Pending'),
                const SizedBox(height: 8),
                const Text(
                  'Note: Order will sync with server when online.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close checkout
                  Navigator.pop(context); // Close cart
                },
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to place order: $e');
    } finally {
      setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _blockController,
              decoration: const InputDecoration(
                labelText: 'Block / Flat Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: '10 digits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            Consumer<CartProvider>(
              builder: (context, cart, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final item in cart.items.values)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.name} x${item.qty}'),
                            Text('₹${item.qty * item.price}'),
                          ],
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${cart.totalPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _placing ? null : _placeOrder,
                child: _placing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
