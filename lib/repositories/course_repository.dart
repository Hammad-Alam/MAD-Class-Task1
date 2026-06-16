import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/course_model.dart';
import '../services/course_api_service.dart';
import '../services/local_database_service.dart';

/// Repository that mediates between the remote API and the local Hive cache.
///
/// Follows an offline-first strategy:
/// - When the device is online, data is fetched from the API and then cached.
/// - When the device is offline, data is served from the local cache.
class CourseRepository {
  CourseRepository({
    required CourseApiService apiService,
    required LocalDatabaseService localDb,
  })  : _apiService = apiService,
        _localDb = localDb;

  final CourseApiService _apiService;
  final LocalDatabaseService _localDb;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  /// Returns the course list.
  ///
  /// • Online  → fetches from API, caches the result, and returns it.
  /// • Offline → returns the last cached snapshot (may be empty).
  /// • If the API call fails (e.g. Chrome DevTools throttling), falls back
  ///   to the local cache instead of throwing.
  Future<List<CourseModel>> fetchCourses({int limit = 20}) async {
    final online = await _isOnline;
    print('[Repository] _isOnline = $online');

    if (online) {
      try {
        final courses = await _apiService.fetchCourses(limit: limit);
        await _localDb.cacheCourses(courses);
        print('[Repository] API success → cached ${courses.length} courses');
        return courses;
      } catch (e) {
        print('[Repository] API failed ($e) → falling back to cache');
      }
    }

    final cached = _localDb.getCachedCourses();
    print('[Repository] Serving ${cached.length} courses from cache');
    return cached;
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  /// Creates a new course via the API and persists it in the local cache.
  /// Falls back to local-only storage when the API is unreachable.
  Future<CourseModel> addCourse(CourseModel course) async {
    if (await _isOnline) {
      try {
        final created = await _apiService.addCourse(course);
        await _localDb.upsertCourse(created);
        return created;
      } catch (_) {
        // API failed – fall through to offline behaviour.
      }
    }

    // Offline or API failed – generate a temporary negative id.
    final offlineCourse = course.copyWith(
      id: -DateTime.now().millisecondsSinceEpoch,
    );
    await _localDb.upsertCourse(offlineCourse);
    return offlineCourse;
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Updates an existing course via the API and mirrors the change locally.
  /// Falls back to local-only update when the API is unreachable.
  Future<CourseModel> updateCourse(CourseModel course) async {
    if (await _isOnline) {
      try {
        final updated = await _apiService.updateCourse(course);
        await _localDb.upsertCourse(updated);
        return updated;
      } catch (_) {
        // API failed – fall through to offline behaviour.
      }
    }

    // Offline or API failed – apply the change locally.
    await _localDb.upsertCourse(course);
    return course;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Deletes the course identified by [courseId] from the API and the cache.
  /// Always removes from local cache regardless of API outcome.
  Future<void> deleteCourse(int courseId) async {
    if (await _isOnline) {
      try {
        await _apiService.deleteCourse(courseId);
      } catch (_) {
        // API failed – still remove from local cache so the UI stays
        // consistent with the optimistic update already applied.
      }
    }
    // Always remove from cache so the UI is correct.
    await _localDb.deleteCourse(courseId);
  }
}
