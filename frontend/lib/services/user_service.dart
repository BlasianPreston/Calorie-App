import 'api_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return await ApiService.get('/user/profile');
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }
}
