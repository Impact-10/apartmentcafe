class Order {
  final String id;
  final String name;
  final String blockDoor;
  final String mobile;
  final Map<String, CartItem> items;
  final int total;
  final String status; // 'pending', 'accepted', 'completed'
  final DateTime createdAt;

  Order({
    required this.id,
    required this.name,
    required this.blockDoor,
    required this.mobile,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromMap(String id, Map<dynamic, dynamic> data) {
    final itemsMap = <String, CartItem>{};
    if (data['items'] is Map) {
      (data['items'] as Map).forEach((key, value) {
        if (value is Map) {
          itemsMap[key] = CartItem.fromMap(value);
        }
      });
    }

    return Order(
      id: id,
      name: data['name'] ?? '',
      blockDoor: data['blockDoor'] ?? '',
      mobile: data['mobile'] ?? '',
      items: itemsMap,
      total: data['total'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'blockDoor': blockDoor,
      'mobile': mobile,
      'items': items.map((k, v) => MapEntry(k, v.toMap())),
      'total': total,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class CartItem {
  final String id;
  final String name;
  final int qty;
  final int price;

  CartItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
  });

  factory CartItem.fromMap(Map<dynamic, dynamic> data) {
    return CartItem(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      qty: data['qty'] ?? 1,
      price: data['price'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'qty': qty, 'price': price};
  }
}
