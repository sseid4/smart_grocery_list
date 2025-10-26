
import 'package:flutter/material.dart';
import '../services/in_memory_repo.dart';
 
import 'edit_detail_screen.dart';


class CategoriesScreen extends StatefulWidget {
 static const routeName = '/categories';
 const CategoriesScreen({super.key});


 @override
 State<CategoriesScreen> createState() => _CategoriesScreenState();
}


class _CategoriesScreenState extends State<CategoriesScreen> {

 final List<String> _categories = [
   'Fruits',
   'Vegetables',
   'Dairy',
   'Bakery',
   'Pantry',
   'Frozen',
   'Household',
 ];


 Future<void> _showAddDialog() async {
   final controller = TextEditingController();
   final result = await showDialog<String?>(
     context: context,
     builder: (ctx) => AlertDialog(
       title: const Text('Add category'),
       content: TextField(
         controller: controller,
         autofocus: true,
         decoration: const InputDecoration(hintText: 'Category name'),
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.of(ctx).pop(),
           child: const Text('Cancel'),
         ),
         ElevatedButton(
           onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
           child: const Text('Add'),
         ),
       ],
     ),
   );


   if (result != null && result.isNotEmpty) {
     setState(() => _categories.add(result));
     ScaffoldMessenger.of(
       context,
     ).showSnackBar(SnackBar(content: Text('Category "$result" added')));
   }
 }


 Future<void> _showRenameDialog(int index) async {
   final controller = TextEditingController(text: _categories[index]);
   final result = await showDialog<String?>(
     context: context,
     builder: (ctx) => AlertDialog(
       title: const Text('Rename category'),
       content: TextField(
         controller: controller,
         autofocus: true,
         decoration: const InputDecoration(hintText: 'New name'),
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.of(ctx).pop(),
           child: const Text('Cancel'),
         ),
         ElevatedButton(
           onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
           child: const Text('Rename'),
         ),
       ],
     ),
   );


   if (result != null && result.isNotEmpty) {
     final old = _categories[index];
     setState(() => _categories[index] = result);
     ScaffoldMessenger.of(
       context,
     ).showSnackBar(SnackBar(content: Text('"$old" renamed to "$result"')));
   }
 }


 void _deleteCategory(int index) {
   final removed = _categories.removeAt(index);
   setState(() {});
   ScaffoldMessenger.of(
     context,
   ).showSnackBar(SnackBar(content: Text('Category "$removed" deleted')));
 }


 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // single-column list; responsiveness handled by ExpansionTile width

          // Build a single list of categories (merge declared categories with
          // any categories present on items so we don't hide categories used by items).
          final repoItems = InMemoryRepo.instance.items.value;
          final catSet = <String>{};
          catSet.addAll(_categories.where((c) => c.isNotEmpty));
          for (var it in repoItems) {
            if (it.category.isNotEmpty) catSet.add(it.category);
          }
          final categories = catSet.toList()..sort();

          Widget listPanel = ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final name = categories[i];
                // Items for this category (case-insensitive match)
                final itemsForCat = repoItems.where((it) => it.category.toLowerCase() == name.toLowerCase()).toList();

                return ExpansionTile(
                  title: Row(children: [Expanded(child: Text(name)), PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        final idx = _categories.indexOf(name);
                        // If name not in the editable list, append then rename on add
                        if (idx == -1) {
                          setState(() => _categories.add(name));
                          _showRenameDialog(_categories.indexOf(name));
                        } else {
                          _showRenameDialog(idx);
                        }
                      } else if (value == 'delete') {
                        showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete category'),
                            content: Text('Delete "$name"? This will not remove items automatically.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        ).then((confirmed) {
                          if (confirmed == true) {
                            final idx = _categories.indexOf(name);
                            if (idx != -1) _deleteCategory(idx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category "$name" deleted')));
                          }
                        });
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  )]),
                  children: itemsForCat.isEmpty
                      ? [Padding(padding: const EdgeInsets.all(12), child: Text('No items in "$name"'))]
                      : itemsForCat.map((it) => ListTile(
                            leading: Checkbox(value: it.purchased, onChanged: (_) => InMemoryRepo.instance.togglePurchased(it.id)),
                            title: Text(it.name),
                            subtitle: Text('Qty: ${it.quantity} • \$${it.price.toStringAsFixed(2)}'),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditDetailScreen(item: it)))),
                              IconButton(icon: const Icon(Icons.delete), onPressed: () { InMemoryRepo.instance.deleteItem(it.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${it.name} deleted'))); }),
                            ]),
                          )).toList(),
                );
              },
            );

          // Single list view: show categories (ExpansionTiles) full width.
          return listPanel;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
 }
}
