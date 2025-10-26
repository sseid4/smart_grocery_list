class Item {
  int id;
  String name;
  int quantity;
  double price;
  String notes;
  String category;
  String priority;
  bool purchased;

  Item({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.price = 0.0,
    this.notes = '',
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
      category: category ?? this.category,
      priority: priority ?? this.priority,
      purchased: purchased ?? this.purchased,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'price': price,
        'notes': notes,
        'category': category,
        'priority': priority,
        'purchased': purchased ? 1 : 0,
      };

  factory Item.fromMap(Map<String, dynamic> m) => Item(
        id: m['id'] as int,
        name: m['name'] as String,
        quantity: m['quantity'] as int? ?? 1,
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        notes: m['notes'] as String? ?? '',
        category: m['category'] as String? ?? '',
        priority: m['priority'] as String? ?? 'Medium',
        purchased: (m['purchased'] as int? ?? 0) == 1,
      );
}
