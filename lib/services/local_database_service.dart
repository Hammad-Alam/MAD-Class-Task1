import 'package:hive_flutter/hive_flutter.dart';

import '../models/course_model.dart';

/// Hive-backed local storage service for course data.
///
/// Stores courses as JSON maps inside a single Hive box so the model layer
/// stays free of Hive-specific annotations.
class LocalDatabaseService {
  static const String _boxName = 'courses_box';
  static const String _coursesKey = 'cached_courses';

  late Box _box;

  /// Opens the Hive box. Must be called once after [Hive.initFlutter].
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ── Courses ──────────────────────────────────────────────────────────────

  /// Persists the full course list, replacing any previously cached data.
  Future<void> cacheCourses(List<CourseModel> courses) async {
    final jsonList = courses.map((c) => c.toJson()).toList();
    await _box.put(_coursesKey, jsonList);
  }

  /// Returns the cached course list, or an empty list when nothing is stored.
  List<CourseModel> getCachedCourses() {
    final raw = _box.get(_coursesKey);
    if (raw == null) return [];

    final list = (raw as List)
        .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return list;
  }

  /// Adds or updates a single course in the cache (matched by [CourseModel.id]).
  Future<void> upsertCourse(CourseModel course) async {
    final courses = getCachedCourses();
    final index = courses.indexWhere((c) => c.id == course.id);
    if (index >= 0) {
      courses[index] = course;
    } else {
      courses.insert(0, course);
    }
    await cacheCourses(courses);
  }

  /// Removes the course identified by [courseId] from the local cache.
  Future<void> deleteCourse(int courseId) async {
    final courses = getCachedCourses();
    courses.removeWhere((c) => c.id == courseId);
    await cacheCourses(courses);
  }

  /// Wipes all cached course data.
  Future<void> clearCourses() async {
    await _box.delete(_coursesKey);
  }
}
