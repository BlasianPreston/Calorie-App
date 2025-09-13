import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await ApiService.login(email, password);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    try {
      return await ApiService.signup(email, password, name);
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await ApiService.logout();
  }

  static Future<bool> isLoggedIn() async {
    return await ApiService.isLoggedIn();
  }
}
