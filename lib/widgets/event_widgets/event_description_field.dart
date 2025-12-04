import 'package:flutter/material.dart';
import 'event_label.dart';

class EventDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const EventDescriptionField({
    super.key,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EventLabel(text: 'Description'),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Décrivez votre événement...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}