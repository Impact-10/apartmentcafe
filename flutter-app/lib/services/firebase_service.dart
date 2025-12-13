import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/schedule.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  void signOut() {
    _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Menu Master CRUD
  Future<void> addMenuMasterItem(MenuItem item) {
    return _database.ref('menuMaster/${item.id}').set(item.toMap());
  }

  Future<void> updateMenuMasterItem(String itemId, MenuItem item) {
    return _database.ref('menuMaster/$itemId').set(item.toMap());
  }

  Future<void> deleteMenuMasterItem(String itemId) {
    return _database.ref('menuMaster/$itemId').remove();
  }

  Stream<List<MenuItem>> streamMenuMaster() {
    return _database.ref('menuMaster').onValue.map((event) {
      final items = <MenuItem>[];
      if (event.snapshot.value is Map) {
        (event.snapshot.value as Map).forEach((key, value) {
          if (value is Map) {
            items.add(MenuItem.fromMap(key, value));
          }
        });
      }
      return items;
    });
  }

  // Active Menu (Customer view)
  Stream<List<MenuItem>> streamActiveMenu() {
    return _database.ref('activeMenu').onValue.map((event) {
      final items = <MenuItem>[];
      if (event.snapshot.value is Map) {
        (event.snapshot.value as Map).forEach((key, value) {
          if (value is Map) {
            items.add(MenuItem.fromMap(key, value));
          }
        });
      }
      return items;
    });
  }

  // Publish active menu (admin): full replace, no duplicates
  Future<void> publishActiveMenu(Map<String, Map<String, dynamic>> menuMap) {
    return _database.ref('activeMenu').set(menuMap);
  }

  // Clear active menu
  Future<void> clearActiveMenu() {
    return _database.ref('activeMenu').set({});
  }

  // Schedule
  Future<void> updateSchedule(ShopSchedule schedule) {
    return _database.ref('shopSchedule').set(schedule.toMap());
  }

  Stream<ShopSchedule> streamSchedule() {
    return _database.ref('shopSchedule').onValue.map((event) {
      if (event.snapshot.value is Map) {
        return ShopSchedule.fromMap(event.snapshot.value as Map);
      }
      return ShopSchedule(
        openTime: '07:00',
        closeTime: '21:00',
        timezone: 'Asia/Kolkata',
        isOpen: false,
        updatedAt: DateTime.now(),
      );
    });
  }

  // Orders
  Future<String> placeOrder(Order order) async {
    final ref = _database.ref('orders').push();
    final orderData = order.toMap();
    // Use server timestamp for createdAt
    orderData['createdAt'] = ServerValue.timestamp;
    await ref.set(orderData);
    return ref.key!;
  }

  Stream<List<Order>> streamPendingOrders() {
    return _database.ref('orders').onValue.map((event) {
      final orders = <Order>[];
      if (event.snapshot.value is Map) {
        (event.snapshot.value as Map).forEach((key, value) {
          if (value is Map) {
            final order = Order.fromMap(key, value);
            if (order.status == 'pending') {
              orders.add(order);
            }
          }
        });
      }
      return orders;
    });
  }

  Stream<List<Order>> streamAcceptedOrders() {
    return _database.ref('orders').onValue.map((event) {
      final orders = <Order>[];
      if (event.snapshot.value is Map) {
        (event.snapshot.value as Map).forEach((key, value) {
          if (value is Map) {
            final order = Order.fromMap(key, value);
            if (order.status == 'accepted') {
              orders.add(order);
            }
          }
        });
      }
      return orders;
    });
  }

  Stream<List<Order>> streamDeliveredOrders() {
    return _database.ref('orders').onValue.map((event) {
      final orders = <Order>[];
      if (event.snapshot.value is Map) {
        (event.snapshot.value as Map).forEach((key, value) {
          if (value is Map) {
            final order = Order.fromMap(key, value);
            if (order.status == 'delivered') {
              orders.add(order);
            }
          }
        });
      }
      return orders;
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final updates = {
      'status': newStatus,
    };
    
    if (newStatus == 'accepted') {
      updates['acceptedAt'] = ServerValue.timestamp;
    } else if (newStatus == 'delivered') {
      updates['deliveredAt'] = ServerValue.timestamp;
    }
    
    await _database.ref('orders/$orderId').update(updates);
  }

  // Archive delivered order to ordersHistory and remove from orders
  Future<void> archiveOrder(Order order) async {
    final date = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final historyRef = _database.ref('ordersHistory/$date/${order.id}');
    final orderRef = _database.ref('orders/${order.id}');
    
    // Get current order data
    final snapshot = await orderRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      // Write to history
      await historyRef.set(snapshot.value);
      // Remove from active orders
      await orderRef.remove();
    }
  }
}
