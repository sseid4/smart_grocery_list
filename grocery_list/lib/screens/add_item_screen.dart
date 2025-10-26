import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/grocery_item.dart';
import '../services/grocery_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _qtyC = TextEditingController(text: '1');
  final _notesC = TextEditingController();
  final _priceC = TextEditingController();

  String _category = 'Produce';
  String _priority = 'Normal';
  bool _isEditing = false;
  int? _editingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg != null && arg is GroceryItem && !_isEditing) {
      _isEditing = true;
      _editingId = arg.id;
      _nameC.text = arg.name;
      _qtyC.text = arg.quantity.toString();
      _notesC.text = arg.notes ?? '';
      _category = arg.category;
      _priority = arg.priority;
      _priceC.text = arg.estimatedPrice?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _qtyC.dispose();
    _notesC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<GroceryProvider>(context, listen: false);

    final item = GroceryItem(
      id: _editingId,
      name: _nameC.text.trim(),
      quantity: int.tryParse(_qtyC.text) ?? 1,
      category: _category,
      notes: _notesC.text.trim().isEmpty ? null : _notesC.text.trim(),
      priority: _priority,
      estimatedPrice: _priceC.text.isEmpty ? null : double.tryParse(_priceC.text),
    );

    if (_isEditing) {
      await provider.updateItem(item);
    } else {
      await provider.addItem(item);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Produce', 'Dairy', 'Bakery', 'Meat', 'Frozen', 'Pantry', 'Snacks', 'Beverages', 'Other'];

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _qtyC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Qty' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? 'Other'),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['Normal', 'Need Today', 'Low Stock'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _priority = v ?? 'Normal'),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceC,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Estimated price (optional)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesC,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Save changes' : 'Add item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

import '../models/item.dart';
import '../services/in_memory_repo.dart';


/// Add Item form with text fields, category dropdown and priority selector.
class AddItemScreen extends StatefulWidget {
 static const routeName = '/add-item';
 const AddItemScreen({super.key});


 @override
 State<AddItemScreen> createState() => _AddItemScreenState();
}


class _AddItemScreenState extends State<AddItemScreen> {
 final _formKey = GlobalKey<FormState>();
 final _nameCtrl = TextEditingController();
 final _quantityCtrl = TextEditingController(text: '1');
 final _priceCtrl = TextEditingController(text: '0.0');


 String? _category;
 String _priority = 'Medium';


 static const List<String> _categories = [
   'Fruits',
   'Vegetables',
   'Dairy',
   'Bakery',
   'Pantry',
   'Meat',
   'Frozen',
 ];


 static const List<String> _priorities = ['High', 'Medium', 'Low'];


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
             TextFormField(
               controller: _nameCtrl,
               decoration: const InputDecoration(labelText: 'Item name'),
               validator: (v) =>
                   (v == null || v.trim().isEmpty) ? 'Enter item name' : null,
             ),
             const SizedBox(height: 12),


             // Category dropdown
             DropdownButtonFormField<String>(
               value: _category,
               decoration: const InputDecoration(labelText: 'Category'),
               items: _categories
                   .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                   .toList(),
               onChanged: (v) => setState(() => _category = v),
               validator: (v) =>
                   (v == null || v.isEmpty) ? 'Select a category' : null,
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
