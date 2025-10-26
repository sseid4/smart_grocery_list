import 'package:flutter/material.dart';


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


             // Priority selector as radio buttons
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
