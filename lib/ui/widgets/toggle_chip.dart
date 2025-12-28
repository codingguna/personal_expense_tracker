// lib/ui/widgets/toggle_chip.dart
import 'package:flutter/material.dart';

class ToggleChip extends StatelessWidget {
  final List<String> values;
  final String selected;
  final Function(String) onChanged;

  const ToggleChip({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values.map((v) {
        final isActive = v == selected;
        return GestureDetector(
          onTap: () => onChanged(v),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF2F8F83)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              v,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
