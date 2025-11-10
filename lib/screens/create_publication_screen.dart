import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() => _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final TextEditingController _contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPublication() async {
    if (_contentController.text.trim().isEmpty) {
      _showMessage('Veuillez écrire un contenu pour votre publication', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showMessage('Vous devez être connecté', Colors.red);
        return;
      }

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final authorName = userData?['fullName'] ?? 'Utilisateur';

      // Create publication in Firestore (sans fichier)
      await _firestore.collection('publications').add({
        'authorId': user.uid,
        'authorName': authorName,
        'content': _contentController.text.trim(),
        'fileUrl': null,  // Pas de fichier
        'fileName': null, // Pas de nom de fichier
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'likedBy': [],
      });

      _showMessage('Publication créée avec succès!', Colors.green);

      // Navigate back after success
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });

    } catch (e) {
      _showMessage('Erreur lors de la création: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer une publication',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPublication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Publier',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.3),
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Section
            const Text(
              'Contenu de la publication',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Exprimez-vous, partagez vos idées ou une annonce importante...\n\n💡 Astuce : Vous pouvez partager des liens vers des ressources externes comme Google Drive, Dropbox, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Partagez vos ressources en collant des liens vers Google Drive, Dropbox, ou autres services de stockage.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}