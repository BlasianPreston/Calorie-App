import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calorie_tracking_app/config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode >= 400) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'An error occurred');
    }
    return response;
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    final responseData = await _handleResponse(response);
    final data = json.decode(responseData.body);
    
    // Store token if login successful
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
    }
    
    return data;
  }

  static Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: await _getHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    
    final responseData = await _handleResponse(response);
    final data = json.decode(responseData.body);
    
    // Store token if signup successful
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
    }
    
    return data;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  // Generic API call method
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    final responseData = await _handleResponse(response);
    return json.decode(responseData.body);
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    
    final responseData = await _handleResponse(response);
    return json.decode(responseData.body);
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    
    final responseData = await _handleResponse(response);
    return json.decode(responseData.body);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    final responseData = await _handleResponse(response);
    return json.decode(responseData.body);
  }
}
