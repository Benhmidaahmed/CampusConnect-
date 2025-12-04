import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/event_service.dart';
import '../services/storage_service.dart';
import '../widgets/event_widgets/event_image_picker.dart';
import '../widgets/event_widgets/event_text_field.dart';
import '../widgets/event_widgets/event_description_field.dart';
import '../widgets/event_widgets/registration_toggle.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  String? _imageUrl;
  bool _isRegistrationOpen = true;

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      if (_selectedImage != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uploadResult = await StorageService.uploadFile(
            _selectedImage!,
            'event_${DateTime.now().millisecondsSinceEpoch}.jpg',
            user.uid,
          );
          _imageUrl = uploadResult['fileUrl'];
        }
      }

      // Create event
      await _eventService.createEvent(
        title: _titleController.text.trim(),
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrl,
        isRegistrationOpen: _isRegistrationOpen,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Créer un événement',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _createEvent,
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text(
            'Créer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2590F4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            EventImagePicker(
              selectedImage: _selectedImage,
              onPickImage: _pickImage,
            ),
            const SizedBox(height: 24),

            // Event Title
            EventTextField(
              controller: _titleController,
              label: 'Titre de l\'événement',
              hintText: 'Ex: Journée Portes Ouvertes 2024',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date and Time Row
            Row(
              children: [
                Expanded(
                  child: EventTextField(
                    controller: _dateController,
                    label: 'Date',
                    hintText: 'Ex: 12 octobre 2024',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EventTextField(
                    controller: _timeController,
                    label: 'Heure',
                    hintText: 'Ex: 09h00 - 17h00',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une heure';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            EventTextField(
              controller: _locationController,
              label: 'Lieu',
              hintText: 'Ex: Campus Principal, Bâtiment A',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un lieu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            EventDescriptionField(
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Registration Toggle
            RegistrationToggle(
              value: _isRegistrationOpen,
              onChanged: (value) {
                setState(() {
                  _isRegistrationOpen = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}