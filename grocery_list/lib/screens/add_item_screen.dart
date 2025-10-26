import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/in_memory_repo.dart';

/// Add Item form with text fields, category dropdown and priority selector.
class AddItemScreen extends StatefulWidget {
  static const routeName = '/add';
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _quantityCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(text: '0.0');

  String? _category;
  String _priority = 'Medium';

  static const List<String> _priorities = ['High', 'Medium', 'Low'];

  // Quick-add presets for commonly used items. Tapping one will immediately
  // add it to the repo with default values so users can add common items fast.
  static const List<Map<String, dynamic>> _quickItems = [
    {'name': 'Milk', 'category': 'Dairy', 'price': 3.5},
    {'name': 'Eggs', 'category': 'Protein', 'price': 5.0},
    {'name': 'Bread', 'category': 'Bakery', 'price': 2.8},
    {'name': 'Bananas', 'category': 'Fruits', 'price': 1.4},
    {'name': 'Apples', 'category': 'Fruits', 'price': 1.6},
    {'name': 'Tomatoes', 'category': 'Vegetables', 'price': 2.2},
    {'name': 'Potatoes', 'category': 'Vegetables', 'price': 2.9},
    {'name': 'Onions', 'category': 'Vegetables', 'price': 1.7},
    {'name': 'Chicken', 'category': 'Protein', 'price': 7.0},
    {'name': 'Rice', 'category': 'Pantry', 'price': 3.5},
    {'name': 'Pasta', 'category': 'Pantry', 'price': 2.6},
    {'name': 'Cheese', 'category': 'Dairy', 'price': 5.0},
    {'name': 'Butter', 'category': 'Dairy', 'price': 4.2},
    {'name': 'Yogurt', 'category': 'Dairy', 'price': 6.0},
    {'name': 'Cereal', 'category': 'Pantry', 'price': 3.5},
    {'name': 'Coffee', 'category': 'Pantry', 'price': 6.0},
    {'name': 'Tea', 'category': 'Pantry', 'price': 3.0},
    {'name': 'Sugar', 'category': 'Pantry', 'price': 1.2},
    {'name': 'Flour', 'category': 'Pantry', 'price': 5.5},
    {'name': 'Olive oil', 'category': 'Pantry', 'price': 11.0},
  ];

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameCtrl.text.trim();
    final quantity = int.tryParse(_quantityCtrl.text) ?? 1;
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final category = _category ?? '';
    final priority = _priority;

    final item = Item(
      id: 0,
      name: name,
      quantity: quantity,
      price: price,
      category: category,
      priority: priority,
    );

    try {
      InMemoryRepo.instance.addItem(item);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving item: $e')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Quick add',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickItems.map((m) {
                  void addImmediate() {
                    final item = Item(
                      id: 0,
                      name: m['name'] as String,
                      quantity: 1,
                      price: (m['price'] as num).toDouble(),
                      category: m['category'] as String,
                      priority: 'Medium',
                    );
                    InMemoryRepo.instance.addItem(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} added')),
                    );
                  }

                  return GestureDetector(
                    onLongPress: () {
                      // Prefill the form so user can edit before saving
                      setState(() {
                        _nameCtrl.text = m['name'] as String;
                        _category = m['category'] as String;
                        _priceCtrl.text = (m['price'] as num).toString();
                        _quantityCtrl.text = '1';
                        _priority = 'Medium';
                      });
                      // focus the name field for convenience
                      FocusScope.of(context).requestFocus(_nameFocus);
                    },
                    child: ActionChip(
                      label: Text(m['name'] as String),
                      onPressed: addImmediate,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter item name' : null,
              ),
              const SizedBox(height: 12),

              // Category dropdown (driven by InMemoryRepo categories)
              ValueListenableBuilder<List<String>>(
                valueListenable: InMemoryRepo.instance.categories,
                builder: (context, cats, _) {
                  final value = (cats.contains(_category)) ? _category : null;
                  return DropdownButtonFormField<String>(
                    initialValue: value,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: cats
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select a category' : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityCtrl,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter quantity';
                        final n = int.tryParse(v);
                        if (n == null || n < 1) return 'Enter valid quantity';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter price';
                        final d = double.tryParse(v);
                        if (d == null || d < 0) return 'Enter valid price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: _priorities
                    .map(
                      (p) => RadioListTile<String>(
                        title: Text(p),
                        value: p,
                        groupValue: _priority,
                        onChanged: (v) =>
                            setState(() => _priority = v ?? 'Medium'),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
