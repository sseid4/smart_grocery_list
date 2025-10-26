import 'dart:convert';

// weekly_plan.dart is not required here; templates store raw plan data as JSON

class WeeklyPlanTemplate {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> planData; // raw serialized plan

  WeeklyPlanTemplate({
    this.id,
    required this.name,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.planData,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    'data': jsonEncode(planData),
  };

  factory WeeklyPlanTemplate.fromMap(Map<String, dynamic> m) {
    final dataStr = m['data'] as String? ?? '{}';
    final data = jsonDecode(dataStr) as Map<String, dynamic>;
    return WeeklyPlanTemplate(
      id: m['id'] as int?,
      name: m['name'] as String? ?? (data['name'] as String? ?? 'Template'),
      description: m['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        m['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        m['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      planData: data,
    );
  }

  int get itemCount {
    final items = planData['items'] as List<dynamic>?;
    return items?.length ?? 0;
  }

  double get estimatedTotal {
    final items = planData['items'] as List<dynamic>?;
    if (items == null) return 0.0;
    double total = 0.0;
    for (final it in items) {
      final price = (it['price'] as num?)?.toDouble() ?? 0.0;
      final qty = it['quantity'] as int? ?? 1;
      total += price * qty;
    }
    return total;
  }
}
