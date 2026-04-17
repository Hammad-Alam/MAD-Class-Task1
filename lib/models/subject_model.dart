class SubjectModel {
  final String name;
  final String description;
  final String schedule;
  final String imageUrl;

  SubjectModel({
    required this.name,
    required this.description,
    required this.schedule,
    required this.imageUrl,
  });

  static List<SubjectModel> getSubjects() {
    return [
      SubjectModel(
        name: 'Mobile App Development',
        description:
            'Learn to build cross-platform mobile applications using Flutter and Dart. '
            'This course covers UI design, state management, navigation, API integration, '
            'and deploying apps to both Android and iOS platforms.',
        schedule: 'Monday & Wednesday, 10:00 AM - 12:00 PM',
        imageUrl: 'mobile_app',
      ),
      SubjectModel(
        name: 'Software Re-engineering',
        description:
            'Study the principles and practices of modernizing legacy software systems. '
            'Topics include reverse engineering, code refactoring, design pattern migration, '
            'and strategies for transforming monolithic architectures into microservices.',
        schedule: 'Tuesday & Thursday, 2:00 PM - 4:00 PM',
        imageUrl: 'software_re',
      ),
      SubjectModel(
        name: 'MIS',
        description:
            'Management Information Systems covers the role of information technology '
            'in business decision-making. Learn about database management, enterprise systems, '
            'IT governance, business intelligence, and how organizations leverage technology.',
        schedule: 'Friday, 9:00 AM - 12:00 PM',
        imageUrl: 'mis',
      ),
    ];
  }
}
