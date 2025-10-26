// Item model: holds id, name, qty, price, notes, imagePath, category, priority, purchased
class Item {
  int id;
  String name;
  int quantity;
  double price;
  String notes;
  String imagePath;
  String category;
  String priority;
  bool purchased;

  Item({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.price = 0.0,
    this.notes = '',
    this.imagePath = '',
    this.category = '',
    this.priority = 'Medium',
    this.purchased = false,
  });

  Item copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
    String? notes,
    String? imagePath,
    String? category,
    String? priority,
    bool? purchased,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      purchased: purchased ?? this.purchased,
    );
  }

  // Convert item to Map for storage/serialization.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'price': price,
    'notes': notes,
    'imagePath': imagePath,
    'category': category,
    'priority': priority,
    'purchased': purchased ? 1 : 0,
  };

  // Create Item from a Map (DB/JSON).
  factory Item.fromMap(Map<String, dynamic> m) => Item(
    id: m['id'] as int,
    name: m['name'] as String,
    quantity: m['quantity'] as int? ?? 1,
    price: (m['price'] as num?)?.toDouble() ?? 0.0,
    notes: m['notes'] as String? ?? '',
    imagePath: m['imagePath'] as String? ?? '',
    category: m['category'] as String? ?? '',
    priority: m['priority'] as String? ?? 'Medium',
    purchased: (m['purchased'] as int? ?? 0) == 1,
  );
}
