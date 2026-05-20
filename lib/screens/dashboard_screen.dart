import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/course_model.dart';
import '../services/course_api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authController = AuthController();
  final _courseApiService = CourseApiService();

  List<CourseModel> _courses = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<IconData> _courseIcons = [
    Icons.phone_android,
    Icons.engineering,
    Icons.business,
    Icons.data_object,
    Icons.menu_book,
    Icons.school,
  ];

  final List<Color> _courseColors = [
    const Color(0xFF6C63FF),
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFF3A86FF),
    const Color(0xFFFF9F1C),
    const Color(0xFF2EC4B6),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses = await _courseApiService.fetchCourses(limit: 20);
      if (!mounted) {
        return;
      }
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showCourseForm({CourseModel? existing}) async {
    final formResult = await showDialog<_CourseFormData>(
      context: context,
      builder: (context) => _CourseFormDialog(existing: existing),
    );

    if (formResult == null) {
      return;
    }

    await _runSubmission(() async {
      if (existing == null) {
        final created = await _courseApiService.addCourse(
          CourseModel(
            userId: _authController.currentUser != null ? 1 : null,
            title: formResult.title,
            description: formResult.description,
          ),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _courses = [created, ..._courses];
        });

        _showMessage('Course added successfully.');
      } else {
        final updated = await _courseApiService.updateCourse(
          existing.copyWith(
            title: formResult.title,
            description: formResult.description,
          ),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _courses = _courses
              .map((course) => course.id == existing.id ? updated : course)
              .toList();
        });

        _showMessage('Course updated successfully.');
      }
    });
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final courseId = course.id;
    if (courseId == null) {
      _showMessage('Cannot delete course without id.', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _runSubmission(() async {
      await _courseApiService.deleteCourse(courseId);
      if (!mounted) {
        return;
      }

      setState(() {
        _courses = _courses.where((item) => item.id != courseId).toList();
      });

      _showMessage('Course deleted successfully.');
    });
  }

  Future<void> _runSubmission(Future<void> Function() operation) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await operation();
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseForm(),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.fullName ?? 'User'}!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Courses (JSONPlaceholder API)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : _fetchCourses,
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildBodyState(),
              ),
            ],
          ),
          if (_isSubmitting)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBodyState() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCourses,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF999999)),
            const SizedBox(height: 10),
            const Text('No courses available.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchCourses,
              child: const Text('Fetch Courses'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCourses,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return _buildCourseCard(context, course, index);
        },
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    CourseModel course,
    int index,
  ) {
    final color = _courseColors[index % _courseColors.length];
    final icon = _courseIcons[index % _courseIcons.length];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: course,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${course.id ?? 'N/A'} | User: ${course.userId ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => _showCourseForm(existing: course),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _deleteCourse(course),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _authController.logout();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _CourseFormData {
  const _CourseFormData({required this.title, required this.description});

  final String title;
  final String description;
}

class _CourseFormDialog extends StatefulWidget {
  const _CourseFormDialog({this.existing});

  final CourseModel? existing;

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Update Course' : 'Add Course'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 4) {
                    return 'Title must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Course description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,
              _CourseFormData(
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
