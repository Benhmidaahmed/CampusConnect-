import 'package:flutter/material.dart';
import 'dart:io';
import 'event_label.dart';

class EventImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;

  const EventImagePicker({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EventLabel(text: 'Image de l\'événement'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Ajouter une image',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}