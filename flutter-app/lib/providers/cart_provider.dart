import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalPrice {
    int total = 0;
    _items.forEach((key, item) {
      total += (item.price * item.qty);
    });
    return total;
  }

  void addItem(MenuItem menuItem, {int qty = 1}) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.qty += qty;
    } else {
      _items[menuItem.id] = CartItem(
        id: menuItem.id,
        name: menuItem.name,
        qty: qty,
        price: menuItem.price,
      );
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int qty) {
    if (qty <= 0) {
      removeItem(itemId);
    } else {
      _items[itemId]?.qty = qty;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final String name;
  int qty;
  final int price;

  CartItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
  });
}
