import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

// Add others if needed (e.g., course_content_page, etc.)

class ApiService {
  // ======================
  // BASE URL (Root only)
  // ======================
  static const String baseUrl = "http://192.168.0.15:8080/api";

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
  static Future<Map<String, dynamic>> signup(String name, String email,
      String password, String role) async {
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

  static Future<Map<String, dynamic>> login(String email,
      String password) async {
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

  // ======================
  // TEACHER COURSES
  // ======================
  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    await _ensureAuth();

    final response = await http.get(
      Uri.parse("$baseUrl/teacher/courses"),
      headers: {"Authorization": "Bearer $_token"},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return List<Map<String, dynamic>>.from(data["data"]);
    } else {
      throw Exception("Failed to load courses: ${data["msg"] ?? "Unknown"}");
    }
  }

  static Future<Map<String, dynamic>> addCourse(String title,
      String description, int price,
      {bool published = true}) async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can add courses.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/teacher/courses"),
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

  static Future<Map<String, dynamic>> updateCourse(int id, String title,
      String description, int price,
      {bool published = true}) async {
    print("----> updateCourse called");
    print(
        "Course ID: $id, Title: $title, Description: $description, Price: $price, Published: $published");

    await _ensureAuth();
    print("Auth ensured. Role: $_role, Token: $_token");

    if (_role?.toUpperCase() != "TEACHER") {
      print("Forbidden: Current role is $_role");
      throw Exception("Forbidden: Only TEACHER can edit courses.");
    }

    final url = "$baseUrl/teacher/courses/$id";
    print("PUT URL: $url");

    final body = jsonEncode({
      "title": title,
      "description": description,
      "price": price,
      "published": published,
    });
    print("Request body: $body");

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: body,
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = jsonDecode(response.body);
      print("Decoded data: $data");

      if (response.statusCode == 200 && data["status"] == "ok") {
        print("Course updated successfully!");
        return Map<String, dynamic>.from(data["data"]);
      } else {
        print("Failed to update course. Message: ${data["msg"]}");
        throw Exception("Failed to update course: ${data["msg"]}");
      }
    } catch (e) {
      print("Exception occurred: $e");
      rethrow;
    }
  }


  static Future<Map<String, dynamic>> getCourseById(int id) async {
    await _ensureAuth();

    final response = await http.get(
      Uri.parse("$baseUrl/teacher/courses/$id"),
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
  // COURSE CONTENT
  // ======================
  static Future<List<Map<String, dynamic>>> fetchCourseContent(
      int courseId) async {
    await _ensureAuth();

    final response = await http.get(
      Uri.parse("$baseUrl/teacher/courses/$courseId/contents"),
      headers: {"Authorization": "Bearer $_token"},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return List<Map<String, dynamic>>.from(data["data"]);
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          "Failed to load course content: ${data["msg"] ?? "Unknown"}");
    }
  }

  static Future<Map<String, dynamic>> addCourseContent({
    required int courseId,
    required String title,
    required String fileType,
    required String fileUrl,
    int? durationSeconds,
    required bool isFree,
  }) async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can add content.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/teacher/courses/$courseId/contents"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode({
        "title": title,
        "fileType": fileType,
        "fileUrl": fileUrl,
        "durationSeconds": durationSeconds,
        "free": isFree,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return Map<String, dynamic>.from(data["data"]);
    } else {
      throw Exception("Failed to add content: ${data["msg"]}");
    }
  }

  static Future<Map<String, dynamic>> updateCourseContent({
    required int courseId,
    required int contentId,
    required String title,
    required String fileType,
    required String fileUrl,
    int? durationSeconds,
    required bool isFree,
  }) async {
    await _ensureAuth();
    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can update content.");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/teacher/courses/$courseId/contents/$contentId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode({
        "title": title,
        "fileType": fileType,
        "fileUrl": fileUrl,
        "durationSeconds": durationSeconds,
        "free": isFree,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["status"] == "ok") {
      return Map<String, dynamic>.from(data["data"]);
    } else {
      throw Exception("Failed to update content: ${data["msg"]}");
    }
  }

  // ======================
  // FILE UPLOAD
  // ======================
  // Replace the uploadCourseFile method in your ApiService class

  static Future<Map<String, dynamic>> uploadCourseFile(File file, {File? thumbnail}) async {
    await _ensureAuth();

    if (_role?.toUpperCase() != "TEACHER") {
      throw Exception("Forbidden: Only TEACHER can upload files.");
    }

    final url = "$baseUrl/teacher/upload";
    print("🟢 Uploading to: $url");
    print("🟢 Token: $_token");
    print("🟢 File exists: ${await file.exists()}");
    print("🟢 File path: ${file.path}");
    if (thumbnail != null) print("🟢 Thumbnail path: ${thumbnail.path}");

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mimeSplit = mimeType.split('/');
    final mediaType = MediaType(mimeSplit[0], mimeSplit[1]);
    print("🟢 Detected MIME type: $mimeType");

    final request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers["Authorization"] = "Bearer $_token";

    // Add main file
    request.files.add(await http.MultipartFile.fromPath(
      "file",
      file.path,
      contentType: mediaType,
    ));

    // Only add thumbnail if it's actually provided (for videos)
    // For documents (PDF/PPT/DOC), thumbnail will be null and won't be sent
    if (thumbnail != null && await thumbnail.exists()) {
      final thumbMimeType = lookupMimeType(thumbnail.path) ?? 'image/jpeg';
      final thumbSplit = thumbMimeType.split('/');
      print("🟢 Adding thumbnail with MIME: $thumbMimeType");
      request.files.add(await http.MultipartFile.fromPath(
        "thumbnail",
        thumbnail.path,
        contentType: MediaType(thumbSplit[0], thumbSplit[1]),
      ));
    } else {
      print("🟡 No thumbnail provided - uploading without thumbnail");
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print("🔵 Response Code: ${response.statusCode}");
    print("🔵 Response Body: $body");

    if (response.statusCode == 200) {
      return jsonDecode(body);
    } else {
      throw Exception("Upload failed [${response.statusCode}]: $body");
    }
  }

}