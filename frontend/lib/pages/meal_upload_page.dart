import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calorie_tracking_app/services/meal_service.dart';
import 'package:calorie_tracking_app/models/meal.dart';

class MealUploadPage extends StatefulWidget {
  const MealUploadPage({super.key});

  @override
  State<MealUploadPage> createState() => _MealUploadPageState();
}

class _MealUploadPageState extends State<MealUploadPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _commentsController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadMeal() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final meal = await MealService.uploadMeal(
        imageFile: _selectedImage!,
        comments: _commentsController.text.trim().isEmpty 
            ? null 
            : _commentsController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal uploaded! Estimated calories: ${meal.calories.toStringAsFixed(0)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        setState(() {
          _selectedImage = null;
          _commentsController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Meal'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview section
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage == null
                  ? InkWell(
                      onTap: _pickImage,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tap to take a photo of your meal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Comments section
            const Text(
              'Comments (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any notes about your meal...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Upload button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadMeal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Analyzing meal...'),
                      ],
                    )
                  : const Text(
                      'Upload & Analyze Meal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Info text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Our AI will analyze your meal photo and estimate the calories. Make sure the food is clearly visible in the image.',
                      style: TextStyle(color: Colors.blue),
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

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}
