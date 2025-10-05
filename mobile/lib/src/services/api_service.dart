import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ======================
  // BASE URL
  // ======================
  static const String baseUrl = "http://192.168.0.15:8080/api/teacher";

  static String? _token;
  static String? _role;

  // ======================
  // TOKEN & ROLE HANDLING
  // ======================
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

  // ======================
  // AUTH
  // ======================
  static Future<Map<String, dynamic>> signup(
      String name, String email, String password, String role) async {
    final url = Uri.parse("http://192.168.0.15:8080/api/auth/register");

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

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("http://192.168.0.15:8080/api/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["token"] != null && data["role"] != null) {
      await _saveAuth(data["token"], data["role"]);
    }

    return data;
  }

  // ======================
  // COURSES (Teacher)
  // ======================

  /// Fetch all courses for logged-in teacher
  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    await _ensureAuth();
    final response = await http.get(
      Uri.parse("$baseUrl/courses"),
      headers: {"Authorization": "Bearer $_token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == "ok") {
      return List<Map<String, dynamic>>.from(data["data"]);
    } else {
      throw Exception("Failed to load courses: ${data["msg"]}");
    }
  }

  /// Add a new course
  static Future<Map<String, dynamic>> addCourse(
      String title, String description, int price,
      {bool published = true}) async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can add courses.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/courses"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "price": price,
        "published": published,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return Map<String, dynamic>.from(data["data"]);
    } else {
      throw Exception("Failed to add course: ${data["msg"]}");
    }
  }

  /// Update existing course
  static Future<Map<String, dynamic>> updateCourse(
      int id, String title, String description, int price,
      {bool published = true}) async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can edit courses.");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/courses/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "price": price,
        "published": published,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return Map<String, dynamic>.from(data["data"]);
    } else {
      throw Exception("Failed to update course: ${data["msg"]}");
    }
  }

  /// Fetch single course by ID
  static Future<Map<String, dynamic>> getCourseById(int id) async {
    await _ensureAuth();

    final response = await http.get(
      Uri.parse("$baseUrl/courses/$id"),
      headers: {"Authorization": "Bearer $_token"},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return Map<String, dynamic>.from(data["data"]);
    } else {
      throw Exception("Failed to fetch course: ${data["msg"]}");
    }
  }

  // ======================
  // FILE UPLOAD (Teacher)
  // ======================
  static Future<Map<String, dynamic>> uploadFile(File file) async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can upload files.");
    }

    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/course-content/upload"));
    request.headers["Authorization"] = "Bearer $_token";
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body);
    } else {
      throw Exception("Upload failed [${response.statusCode}]: $body");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUploadedFiles() async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can view uploaded files.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/course-content/files"),
      headers: {"Authorization": "Bearer $_token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is Map && data["status"] == "ok") {
        return List<Map<String, dynamic>>.from(data["data"]);
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Unexpected response format for uploaded files.");
      }
    } else {
      throw Exception("Failed to fetch uploaded files: ${response.statusCode}");
    }
  }
}
