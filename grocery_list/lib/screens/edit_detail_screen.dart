import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item.dart';
import '../services/in_memory_repo.dart';

// Editable item view with update and delete actions.
class EditDetailScreen extends StatefulWidget {
  static const routeName = '/edit-detail';
  final Item? item;

  const EditDetailScreen({super.key, this.item});

  @override
  State<EditDetailScreen> createState() => _EditDetailScreenState();
}

class _EditDetailScreenState extends State<EditDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _notesCtrl;
  String? _category;
  String _priority = 'Medium';

  static const List<String> _priorities = ['High', 'Medium', 'Low'];

  late Item _item;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _item =
        widget.item ??
        Item(
          id: 1,
          name: 'Mock Item',
          quantity: 2,
          price: 1.99,
          category: 'Pantry',
        );

    _nameCtrl = TextEditingController(text: _item.name);
    _quantityCtrl = TextEditingController(text: _item.quantity.toString());
    _priceCtrl = TextEditingController(text: _item.price.toString());
    _category = _item.category;
    _priority = _item.priority;
    _notesCtrl = TextEditingController(text: _item.notes);
    _imagePath = _item.imagePath.isNotEmpty ? _item.imagePath : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = _item.copyWith(
      name: _nameCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text) ?? 1,
      price: double.tryParse(_priceCtrl.text) ?? 0.0,
      notes: _notesCtrl.text.trim(),
      category: _category ?? '',
      priority: _priority,
      imagePath: _imagePath ?? '',
    );

    InMemoryRepo.instance.updateItem(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item updated'),
        duration: const Duration(milliseconds: 900),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (picked != null) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm == true) {
      InMemoryRepo.instance.deleteItem(_item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted'),
          duration: const Duration(milliseconds: 900),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit / Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
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
                        if (v == null || v.isEmpty) return 'Enter a quantity';
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
                        if (v == null || v.isEmpty) return 'Enter a price';
                        final d = double.tryParse(v);
                        if (d == null || d < 0) return 'Enter valid price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          (_imagePath != null && _imagePath!.isNotEmpty)
                          ? FileImage(File(_imagePath!)) as ImageProvider
                          : null,
                      child: (_imagePath == null || _imagePath!.isEmpty)
                          ? const Icon(Icons.image)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Change image'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _priorities.map((p) {
                  final selected = _priority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (sel) {
                      if (sel) setState(() => _priority = p);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onUpdate,
                      icon: const Icon(Icons.save),
                      label: const Text('Update'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _onDelete,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
