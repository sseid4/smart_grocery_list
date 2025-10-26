import 'item.dart';

class PlannedItem {
  final Item item;
  int quantity;

  PlannedItem({required this.item, int? quantity})
    : quantity = quantity ?? item.quantity;

  double get estimatedPrice => (item.price) * quantity;
}

class WeeklyPlan {
  final String name;
  final DateTime createdAt;
  final List<PlannedItem> items;

  WeeklyPlan({
    required this.name,
    DateTime? createdAt,
    List<PlannedItem>? items,
  }) : createdAt = createdAt ?? DateTime.now(),
       items = items ?? [];

  double get totalEstimated =>
      items.fold(0.0, (s, it) => s + it.estimatedPrice);
}
