/// Represents the current state of the course data pipeline.
enum CourseStateStatus {
  /// Initial state before any data is loaded.
  initial,

  /// Currently loading data from API or local storage.
  loading,

  /// Data loaded successfully (may be empty list).
  success,

  /// An error occurred while loading or performing an action.
  error,
}
