class MenuItem {
  final String id;
  final String name;
  final int price;
  final String meal; // 'breakfast', 'lunch', 'snack', 'dinner'
  final bool enabled;
  final String imageUrl;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.meal,
    required this.enabled,
    required this.imageUrl,
    required this.description,
  });

  factory MenuItem.fromMap(String id, Map<dynamic, dynamic> data) {
    return MenuItem(
      id: id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      meal: data['meal'] ?? 'snack',
      enabled: data['enabled'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'meal': meal,
      'enabled': enabled,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
