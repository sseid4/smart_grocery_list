import 'package:flutter/material.dart';


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
     body: ListView.separated(
       padding: const EdgeInsets.all(12),
       itemCount: _categories.length,
       itemBuilder: (ctx, i) {
         final name = _categories[i];
         return ListTile(
           title: Text(name),
           trailing: PopupMenuButton<String>(
             onSelected: (value) {
               if (value == 'rename') {
                 _showRenameDialog(i);
               } else if (value == 'delete') {

                 showDialog<bool>(
                   context: context,
                   builder: (c) => AlertDialog(
                     title: const Text('Delete category'),
                     content: Text(
                       'Delete "$name"? This will not remove items automatically.',
                     ),
                     actions: [
                       TextButton(
                         onPressed: () => Navigator.of(c).pop(false),
                         child: const Text('Cancel'),
                       ),
                       ElevatedButton(
                         onPressed: () => Navigator.of(c).pop(true),
                         child: const Text('Delete'),
                       ),
                     ],
                   ),
                 ).then((confirmed) {
                   if (confirmed == true) _deleteCategory(i);
                 });
               }
             },
             itemBuilder: (_) => const [
               PopupMenuItem(value: 'rename', child: Text('Rename')),
               PopupMenuItem(value: 'delete', child: Text('Delete')),
             ],
           ),
           onTap: () {
             ScaffoldMessenger.of(
               context,
             ).showSnackBar(SnackBar(content: Text('Open category: $name')));
           },
         );
       },
       separatorBuilder: (_, __) => const Divider(height: 1),
     ),
     floatingActionButton: FloatingActionButton.extended(
       onPressed: _showAddDialog,
       icon: const Icon(Icons.add),
       label: const Text('Add Category'),
     ),
   );
 }
}
