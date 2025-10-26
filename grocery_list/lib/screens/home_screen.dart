import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/grocery_provider.dart';
import '../services/grocery_item.dart';
import '../models/item.dart';
import '../services/in_memory_repo.dart';
import 'add_item_screen.dart';
import 'edit_detail_screen.dart';
import 'categories_screen.dart';
import 'weekly_generator_screen.dart';
import 'settings_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 static const routeName = '/';
 const HomeScreen({super.key});


 @override
 State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroceryProvider>(context);
    final items = provider.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.notes ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Grocery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadItems(),
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear all items?'),
                  content: const Text('This will remove all items permanently.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                  ],
                ),
              );
              if (ok == true) await provider.clearAll();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items or categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add.'))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final GroceryItem item = items[i];
                return ListTile(
                  leading: Checkbox(
                    value: item.purchased,
                    onChanged: (_) => provider.togglePurchased(item),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.purchased ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${item.quantity} • ${item.category} ${item.priority == 'Need Today' ? '• 🔥' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.estimatedPrice != null) Text('\$${item.estimatedPrice!.toStringAsFixed(2)}'),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          // navigate to edit screen (not implemented yet)
                          // pass item.id via arguments, or implement inline bottom-sheet edit
                          // For now open add screen prefilled (quick hack)
                          Navigator.pushNamed(ctx, '/add', arguments: item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => provider.deleteItem(item.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
 String _query = '';


 void _openAddItem() async {
   await Navigator.pushNamed(context, AddItemScreen.routeName);
   // no need to setState; repo notifies listeners
 }


 void _openCategories() =>
     Navigator.pushNamed(context, CategoriesScreen.routeName);
 void _openWeekly() =>
     Navigator.pushNamed(context, WeeklyGeneratorScreen.routeName);
 void _openSettings() =>
     Navigator.pushNamed(context, SettingsScreen.routeName);


 void _openEdit(Item item) async {
   await Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => EditDetailScreen(item: item)),
   );
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: const Text('Home')),
     body: Column(
       children: [
         Padding(
           padding: const EdgeInsets.all(12.0),
           child: TextField(
             decoration: const InputDecoration(
               labelText: 'Search',
               prefixIcon: Icon(Icons.search),
               border: OutlineInputBorder(),
             ),
             onChanged: (v) => setState(() => _query = v),
           ),
         ),
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 12.0),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               ElevatedButton.icon(
                 onPressed: _openAddItem,
                 icon: const Icon(Icons.add),
                 label: const Text('Add Item'),
               ),
               ElevatedButton.icon(
                 onPressed: _openCategories,
                 icon: const Icon(Icons.category),
                 label: const Text('Cat'),
               ),
               ElevatedButton.icon(
                 onPressed: _openWeekly,
                 icon: const Icon(Icons.calendar_today),
                 label: const Text('Weekly'),
               ),
               IconButton(
                 onPressed: _openSettings,
                 icon: const Icon(Icons.settings),
               ),
             ],
           ),
         ),
         const SizedBox(height: 8),
         Expanded(
           child: ValueListenableBuilder<List<Item>>(
             valueListenable: InMemoryRepo.instance.items,
             builder: (context, list, _) {
               final filtered = list
                   .where(
                     (it) =>
                         it.name.toLowerCase().contains(_query.toLowerCase()),
                   )
                   .toList();
               if (filtered.isEmpty)
                 return const Center(
                   child: Text('No items match your search.'),
                 );
               return ListView.separated(
                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
                 itemBuilder: (ctx, i) {
                   final it = filtered[i];
                   // find original index in repo for undo restore
                   final originalIndex = InMemoryRepo.instance.items.value
                       .indexWhere((e) => e.id == it.id);


                   return Dismissible(
                     key: ValueKey('item-${it.id}'),
                     direction: DismissDirection.endToStart,
                     background: Container(
                       alignment: Alignment.centerRight,
                       padding: const EdgeInsets.only(right: 20),
                       color: Colors.red,
                       child: const Icon(
                         Icons.delete,
                         color: Color.fromARGB(255, 28, 28, 28),
                       ),
                     ),
                     onDismissed: (direction) {
                       // remove and show undo
                       InMemoryRepo.instance.deleteItem(it.id);
                       ScaffoldMessenger.of(context).clearSnackBars();
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('${it.name} deleted'),
                           action: SnackBarAction(
                             label: 'Undo',
                             onPressed: () {
                               InMemoryRepo.instance.restoreItem(
                                 it,
                                 index: originalIndex,
                               );
                             },
                           ),
                         ),
                       );
                     },
                     child: ListTile(
                       leading: Checkbox(
                         value: it.purchased,
                         onChanged: (_) =>
                             InMemoryRepo.instance.togglePurchased(it.id),
                       ),
                       title: AnimatedDefaultTextStyle(
                         style: it.purchased
                             ? TextStyle(
                                 decoration: TextDecoration.lineThrough,
                                 color:
                                     Theme.of(context)
                                         .textTheme
                                         .bodyLarge
                                         ?.color
                                         ?.withOpacity(0.6) ??
                                     Colors.grey,
                               )
                             : TextStyle(
                                 decoration: TextDecoration.none,
                                 color: Theme.of(
                                   context,
                                 ).textTheme.bodyLarge?.color,
                               ),
                         duration: const Duration(milliseconds: 200),
                         child: Text(it.name),
                       ),
                       subtitle: AnimatedOpacity(
                         opacity: it.purchased ? 0.5 : 1.0,
                         duration: const Duration(milliseconds: 200),
                         child: Text(
                           'Qty: ${it.quantity}  •  \$${it.price.toStringAsFixed(2)}',
                           style: TextStyle(
                             color: Theme.of(
                               context,
                             ).textTheme.bodyMedium?.color,
                           ),
                         ),
                       ),
                       trailing: IconButton(
                         icon: const Icon(Icons.edit),
                         onPressed: () => _openEdit(it),
                       ),
                       onTap: () => _openEdit(it),
                     ),
                   );
                 },
                 separatorBuilder: (_, __) => const Divider(height: 1),
                 itemCount: filtered.length,
               );
             },
           ),
         ),
       ],
     ),
   );
 }
}
