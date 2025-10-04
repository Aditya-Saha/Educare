import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL (replace with your LAN/WiFi IP)
  static const String baseUrl = "http://192.168.0.106:8080/api";

  static String? _token;
  static String? _role;

  /// ======================
  /// TOKEN & ROLE HANDLING
  /// ======================

  static Future<void> _saveAuth(String token, String role) async {
    _token = token;
    _role = role;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", role);
  }

  static Future<void> _ensureAuth() async {
    if (_token == null || _role == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("token");
      _role = prefs.getString("role");
    }
    if (_token == null || _role == null) {
      throw Exception("No token/role found. Please log in again.");
    }
  }

  static String? get token => _token;
  static String? get role => _role;

  /// ======================
  /// AUTH
  /// ======================

  static Future<Map<String, dynamic>> signup(
      String name, String email, String password, String role) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["token"] != null &&
        data["role"] != null) {
      await _saveAuth(data["token"], data["role"]);
    }

    return data;
  }

  /// ======================
  /// COURSES
  /// ======================

  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    final url = Uri.parse("$baseUrl/courses");

    await _ensureAuth();
    final headers = {"Authorization": "Bearer $_token"};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load courses: ${response.statusCode}");
    }
  }

  /// ======================
  /// CHECKOUT (Student)
  /// ======================

  static Future<Map<String, dynamic>> checkout(
      List<Map<String, dynamic>> cartItems) async {
    final url = Uri.parse("$baseUrl/checkout");

    await _ensureAuth();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_token",
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"cart": cartItems}),
    );

    return jsonDecode(response.body);
  }

  /// ======================
  /// FILE UPLOAD (Teacher)
  /// ======================

  static Future<Map<String, dynamic>> uploadFile(File file) async {
    final url = Uri.parse("$baseUrl/teacher/course-content/upload");

    await _ensureAuth();

    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can upload files.");
    }

    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $_token";
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body);
    } else if (response.statusCode == 403) {
      throw Exception("Forbidden: You must be logged in as a TEACHER.");
    } else {
      throw Exception("Upload failed [${response.statusCode}]: $body");
    }
  }

  /// ======================
  /// FETCH UPLOADED FILES (Teacher)
  /// ======================
  static Future<List<Map<String, dynamic>>> fetchUploadedFiles() async {
    final url = Uri.parse("$baseUrl/teacher/course-content/files");

    await _ensureAuth();

    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can view uploaded files.");
    }

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Handle both styles of API response
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data["files"] is List) {
        return List<Map<String, dynamic>>.from(data["files"]);
      } else {
        throw Exception("Unexpected response format for uploaded files.");
      }
    } else {
      throw Exception("Failed to fetch uploaded files: ${response.statusCode}");
    }
  }
}
