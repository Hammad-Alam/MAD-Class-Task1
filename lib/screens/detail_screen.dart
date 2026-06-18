import 'package:flutter/material.dart';
import '../models/course_model.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  Color _resolveColor(int? id) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFF3A86FF),
      Color(0xFFFF9F1C),
      Color(0xFF2EC4B6),
    ];

    if (id == null) {
      return colors.first;
    }

    return colors[id % colors.length];
  }

  IconData _resolveIcon(int? id) {
    const icons = [
      Icons.menu_book,
      Icons.school,
      Icons.data_object,
      Icons.code,
      Icons.analytics,
      Icons.computer,
    ];

    if (id == null) {
      return icons.first;
    }

    return icons[id % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final course = ModalRoute.of(context)!.settings.arguments as CourseModel;
    final color = _resolveColor(course.id);
    final icon = _resolveIcon(course.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Course #${course.id ?? '-'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Course Title',
                    icon: Icons.info_outline,
                    color: color,
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Description',
                    icon: Icons.schedule,
                    color: color,
                    child: Text(
                      course.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Course Details',
                    icon: Icons.list_alt,
                    color: color,
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.tag, 'Course ID', '${course.id ?? 'N/A'}', color),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.person, 'Owner User ID', '${course.userId ?? 'N/A'}', color),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.cloud_done, 'Source', 'JSONPlaceholder /posts', color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
