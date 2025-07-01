import 'package:http/http.dart' as http;
import 'dart:convert';
import 'server_config.dart';
import 'dart:io';

class ApiService {
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/get_user_details');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> uploadBiometric({
    required String userId,
    required String userName,
    required File imageFile,
  }) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/biometric');
    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['user_id'] = userId
        ..fields['user_name'] = userName
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateWallet({
    required String userId,
    required String userName,
    required double amount,
  }) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/wallet_update');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'user_name': userName,
          'amount': amount,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserDetailsById(String userId) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/get_user_details_by_id');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
