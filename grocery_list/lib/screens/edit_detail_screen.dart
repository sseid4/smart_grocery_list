import 'package:flutter/material.dart';

/// Skeleton for Edit / Detail Screen. Keep signature so callers can pass an
/// optional `item` map; implementation is left for the team.
class EditDetailScreen extends StatelessWidget {
  static const routeName = '/edit-detail';
  final Map<String, dynamic>? item;

  const EditDetailScreen({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit / Detail')),
      body: Center(
        child: Text(
          item == null
              ? 'TODO: Implement Edit/Detail screen'
              : 'TODO: Edit item: ${item!['name'] ?? ''}',
        ),
      ),
    );
  }
}
