class CourseModel {
  final int? userId;
  final int? id;
  final String title;
  final String description;

  const CourseModel({
    this.userId,
    this.id,
    required this.title,
    required this.description,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      userId: json['userId'] as int?,
      id: json['id'] as int?,
      title: (json['title'] as String? ?? '').trim(),
      description: (json['body'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (id != null) 'id': id,
      'title': title,
      'body': description,
    };
  }

  CourseModel copyWith({
    int? userId,
    int? id,
    String? title,
    String? description,
  }) {
    return CourseModel(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
