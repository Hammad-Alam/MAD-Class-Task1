import 'package:flutter/foundation.dart';

import '../enums/course_state.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

/// Manages all course-related UI state using [ChangeNotifier].
///
/// Supports:
/// - Loading / success / error / empty states
/// - Optimistic UI updates with automatic rollback on failure
/// - In-memory search / filter by title or description
class CourseProvider extends ChangeNotifier {
  CourseProvider({required CourseRepository repository})
      : _repository = repository;

  final CourseRepository _repository;

  // ── State fields ────────────────────────────────────────────────────────

  CourseStateStatus _status = CourseStateStatus.initial;
  CourseStateStatus get status => _status;

  List<CourseModel> _courses = [];
  List<CourseModel> get courses => _courses;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Currently active search query (empty string means no filter).
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Whether a background CRUD operation (add / update / delete) is in progress.
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ── Derived / filtered list ──────────────────────────────────────────────

  /// Returns courses filtered by [_searchQuery] (case-insensitive).
  List<CourseModel> get filteredCourses {
    if (_searchQuery.isEmpty) return _courses;

    final query = _searchQuery.toLowerCase();
    return _courses.where((c) {
      return c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query);
    }).toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchCourses({int limit = 20}) async {
    _status = CourseStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _repository.fetchCourses(limit: limit);
      _status = CourseStateStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = CourseStateStatus.error;
    }

    notifyListeners();
  }

  // ── Add (optimistic) ─────────────────────────────────────────────────────

  Future<void> addCourse(CourseModel course) async {
    _isSubmitting = true;
    notifyListeners();

    // Optimistic insert – immediately show the new course at the top.
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticCourse = course.copyWith(id: tempId);
    _courses = [optimisticCourse, ..._courses];
    notifyListeners();

    try {
      final created = await _repository.addCourse(course);

      // Replace the optimistic entry with the real one.
      _courses = _courses
          .map((c) => c.id == tempId ? created : c)
          .toList();
    } catch (e) {
      // Rollback – remove the optimistic entry.
      _courses = _courses.where((c) => c.id != tempId).toList();
      _errorMessage = e.toString();
      _status = CourseStateStatus.error;
    }

    _isSubmitting = false;
    notifyListeners();
  }

  // ── Update (optimistic) ──────────────────────────────────────────────────

  Future<void> updateCourse(CourseModel existing, CourseModel updated) async {
    _isSubmitting = true;
    notifyListeners();

    // Snapshot for rollback.
    final previousCourses = List<CourseModel>.from(_courses);

    // Optimistic update – swap in the new data immediately.
    _courses = _courses
        .map((c) => c.id == existing.id ? updated : c)
        .toList();
    notifyListeners();

    try {
      final result = await _repository.updateCourse(updated);

      // Sync with the server-returned version (e.g. updated timestamps).
      _courses = _courses
          .map((c) => c.id == existing.id ? result : c)
          .toList();
    } catch (e) {
      // Rollback.
      _courses = previousCourses;
      _errorMessage = e.toString();
      _status = CourseStateStatus.error;
    }

    _isSubmitting = false;
    notifyListeners();
  }

  // ── Delete (optimistic) ──────────────────────────────────────────────────

  Future<void> deleteCourse(CourseModel course) async {
    final courseId = course.id;
    if (courseId == null) return;

    _isSubmitting = true;
    notifyListeners();

    // Snapshot for rollback.
    final previousCourses = List<CourseModel>.from(_courses);

    // Optimistic removal.
    _courses = _courses.where((c) => c.id != courseId).toList();
    notifyListeners();

    try {
      await _repository.deleteCourse(courseId);
    } catch (e) {
      // Rollback – restore the removed course.
      _courses = previousCourses;
      _errorMessage = e.toString();
      _status = CourseStateStatus.error;
    }

    _isSubmitting = false;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Clears the error message without triggering a full refetch.
  void clearError() {
    _errorMessage = null;
    if (_courses.isNotEmpty) {
      _status = CourseStateStatus.success;
    }
    notifyListeners();
  }
}
