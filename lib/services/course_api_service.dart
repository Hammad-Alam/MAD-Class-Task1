import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course_model.dart';

class CourseApiService {
  CourseApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _baseUri = Uri.parse('https://jsonplaceholder.typicode.com');
  final http.Client _client;

  Future<List<CourseModel>> fetchCourses({int limit = 20}) async {
    final uri = _baseUri.replace(path: '/posts', queryParameters: {'_limit': '$limit'});
    final response = await _client.get(uri);
    _throwIfNotSuccess(response, 'Failed to fetch courses');

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CourseModel> addCourse(CourseModel course) async {
    final uri = _baseUri.replace(path: '/posts');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );
    _throwIfNotSuccess(response, 'Failed to add course');

    return CourseModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CourseModel> updateCourse(CourseModel course) async {
    if (course.id == null) {
      throw const CourseApiException('Course id is required for update');
    }

    final uri = _baseUri.replace(path: '/posts/${course.id}');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );
    _throwIfNotSuccess(response, 'Failed to update course');

    return CourseModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteCourse(int courseId) async {
    final uri = _baseUri.replace(path: '/posts/$courseId');
    final response = await _client.delete(uri);
    _throwIfNotSuccess(response, 'Failed to delete course');
  }

  void _throwIfNotSuccess(http.Response response, String fallbackMessage) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    throw CourseApiException('$fallbackMessage (status: $statusCode)');
  }
}

class CourseApiException implements Exception {
  const CourseApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
