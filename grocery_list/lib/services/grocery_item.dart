class GroceryItem {
  int? id;
  String name;
  int quantity;
  String category;
  String? notes;
  bool purchased;
  String priority; // e.g., 'Normal', 'Need Today'
  double? estimatedPrice; // optional
  String? imagePath; // optional local path to image

  GroceryItem({
    this.id,
    required this.name,
    this.quantity = 1,
    this.category = 'Uncategorized',
    this.notes,
    this.purchased = false,
    this.priority = 'Normal',
    this.estimatedPrice,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'category': category,
      'notes': notes,
      'purchased': purchased ? 1 : 0,
      'priority': priority,
      'estimatedPrice': estimatedPrice,
      'imagePath': imagePath,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int? ?? 1,
      category: map['category'] as String? ?? 'Uncategorized',
      notes: map['notes'] as String?,
      purchased: (map['purchased'] == 1),
      priority: map['priority'] as String? ?? 'Normal',
      estimatedPrice: map['estimatedPrice'] == null
          ? null
          : (map['estimatedPrice'] as num).toDouble(),
      imagePath: map['imagePath'] as String?,
    );
  }
}
