import 'package:flutter/material.dart';

Color _priorityColor(String p) {
  final low = p.toLowerCase();
  if (low.contains('high')) return Colors.red.shade600;
  if (low.contains('med')) return Colors.orange.shade600;
  return Colors.green.shade600;
}

String _shortLabel(String p) {
  final low = p.toLowerCase();
  if (low.contains('high')) return 'High';
  if (low.contains('med')) return 'Med';
  return 'Low';
}

class PriorityIndicator extends StatelessWidget {
  final String priority;
  final bool showLabel;
  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = _priorityColor(priority);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            _shortLabel(priority),
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
