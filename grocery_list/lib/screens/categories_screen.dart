import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/icon_mapper.dart';
import 'package:image_picker/image_picker.dart';

import '../services/in_memory_repo.dart';
import '../widgets/priority_indicator.dart';

import 'edit_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/categories';
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    String? pickedImage;
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            return AlertDialog(
              title: const Text('Add category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Category name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            final XFile? p = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (p != null)
                              setState2(() => pickedImage = p.path);
                          } catch (e) {}
                        },
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (pickedImage != null)
                              ? FileImage(File(pickedImage!))
                              : null,
                          child: (pickedImage == null)
                              ? const Icon(Icons.image)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            try {
                              final XFile? p = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                              );
                              if (p != null)
                                setState2(() => pickedImage = p.path);
                            } catch (e) {}
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select image (optional)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      InMemoryRepo.instance.addCategoryWithImage(
        result,
        imagePath: pickedImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$result" added'),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  Future<void> _showRenameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    String? pickedImage;
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            return AlertDialog(
              title: const Text('Rename category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'New name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            final XFile? p = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (p != null)
                              setState2(() => pickedImage = p.path);
                          } catch (e) {}
                        },
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (pickedImage != null)
                              ? FileImage(File(pickedImage!))
                              : null,
                          child: (pickedImage == null)
                              ? const Icon(Icons.image)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            try {
                              final XFile? p = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                              );
                              if (p != null)
                                setState2(() => pickedImage = p.path);
                            } catch (e) {}
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select image (optional)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: const Text('Rename'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final cats = InMemoryRepo.instance.categories.value;
      final idx = cats.indexWhere(
        (c) => c.toLowerCase() == currentName.toLowerCase(),
      );
      if (idx != -1) {
        InMemoryRepo.instance.renameCategory(idx, result);
        if (pickedImage != null) {
          InMemoryRepo.instance.setCategoryImage(result, pickedImage);
        }
      } else {
        InMemoryRepo.instance.addCategoryWithImage(
          result,
          imagePath: pickedImage,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$currentName" renamed to "$result"'),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _deleteCategory(String name) {
    final cats = InMemoryRepo.instance.categories.value;
    final idx = cats.indexWhere((c) => c.toLowerCase() == name.toLowerCase());
    if (idx != -1) InMemoryRepo.instance.deleteCategory(idx);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$name" deleted'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: InMemoryRepo.instance.categories,
        builder: (context, cats, __) {
          return ValueListenableBuilder<List<dynamic>>(
            valueListenable: InMemoryRepo.instance.items,
            builder: (context, repoItems, _) {
              // single-column list; responsiveness handled by ExpansionTile width

              // Build a single list of categories (merge declared categories with
              // any categories present on items so we don't hide categories used by items).
              final catSet = <String>{};
              catSet.addAll(cats.where((c) => c.isNotEmpty));
              for (var it in repoItems) {
                if ((it?.category ?? '').isNotEmpty) catSet.add(it.category);
              }
              final categories = catSet.toList()..sort();

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final name = categories[i];
                  // Items for this category (case-insensitive match)
                  final itemsForCat = repoItems
                      .where(
                        (it) =>
                            (it?.category ?? '').toLowerCase() ==
                            name.toLowerCase(),
                      )
                      .toList();

                  return ExpansionTile(
                    title: Row(
                      children: [
                        // category image if present, otherwise emoji derived from name
                        Builder(
                          builder: (ctx) {
                            final images =
                                InMemoryRepo.instance.categoryImages.value;
                            final path = images[name];
                            if (path != null && path.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: FileImage(File(path)),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              );
                            }
                            final emoji = emojiForCategoryName(name);
                            if (emoji != null) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Expanded(child: Text(name)),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'rename') {
                              _showRenameDialog(name);
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
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ).then((confirmed) {
                                if (confirmed == true) {
                                  _deleteCategory(name);
                                }
                              });
                            } else if (value == 'set_image') {
                              try {
                                final XFile? p = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (p != null) {
                                  InMemoryRepo.instance.setCategoryImage(
                                    name,
                                    p.path,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Image set for "$name"'),
                                      duration: const Duration(
                                        milliseconds: 900,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // ignore
                              }
                            } else if (value == 'clear_image') {
                              InMemoryRepo.instance.setCategoryImage(
                                name,
                                null,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Image cleared for "$name"'),
                                  duration: const Duration(milliseconds: 900),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            const PopupMenuItem(
                              value: 'set_image',
                              child: Text('Change image'),
                            ),
                            const PopupMenuItem(
                              value: 'clear_image',
                              child: Text('Clear image'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: itemsForCat.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('No items in "$name"'),
                            ),
                          ]
                        : itemsForCat
                              .map(
                                (it) => ListTile(
                                  leading: Checkbox(
                                    value: it.purchased,
                                    onChanged: (_) => InMemoryRepo.instance
                                        .togglePurchased(it.id),
                                  ),
                                  title: Row(
                                    children: [
                                      PriorityIndicator(priority: it.priority),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(it.name)),
                                    ],
                                  ),
                                  subtitle: Text(
                                    'Qty: ${it.quantity} • \$${it.price.toStringAsFixed(2)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditDetailScreen(item: it),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          InMemoryRepo.instance.deleteItem(
                                            it.id,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${it.name} deleted',
                                              ),
                                              duration: const Duration(
                                                milliseconds: 900,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                  );
                },
              );
            },
          );
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
