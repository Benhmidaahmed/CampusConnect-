import 'package:flutter/material.dart';

class RegistrationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RegistrationToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2590F4),
        ),
        const SizedBox(width: 8),
        const Text(
          'Inscriptions ouvertes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}