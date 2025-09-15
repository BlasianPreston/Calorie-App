import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calorie_tracking_app/models/meal.dart';
import 'package:calorie_tracking_app/services/api_service.dart';

class MealService {
  static Future<Meal> uploadMeal({
    File? imageFile,
    Uint8List? imageBytes,
    String? comments,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/meals/upload'),
      );

      // Add headers
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final headers = {
        if (token != null) 'Authorization': 'Bearer $token',
      };
      request.headers.addAll(headers);

      // Add image file
      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'image.jpg',
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      } else {
        throw Exception('No image provided');
      }

      // Add comments if provided
      if (comments != null && comments.isNotEmpty) {
        request.fields['comments'] = comments;
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload meal');
      }

      final data = json.decode(response.body);
      return Meal.fromJson(data['meal']);
    } catch (e) {
      throw Exception('Failed to upload meal: ${e.toString()}');
    }
  }

  static Future<List<Meal>> getMealHistory() async {
    try {
      final response = await ApiService.get('/meals/history');
      final meals = (response['meals'] as List)
          .map((json) => Meal.fromJson(json))
          .toList();
      return meals;
    } catch (e) {
      throw Exception('Failed to fetch meal history: ${e.toString()}');
    }
  }

  static Future<Meal> getMealById(String id) async {
    try {
      final response = await ApiService.get('/meals/$id');
      return Meal.fromJson(response['meal']);
    } catch (e) {
      throw Exception('Failed to fetch meal: ${e.toString()}');
    }
  }

  static Future<void> deleteMeal(String id) async {
    try {
      await ApiService.delete('/meals/$id');
    } catch (e) {
      throw Exception('Failed to delete meal: ${e.toString()}');
    }
  }
}
