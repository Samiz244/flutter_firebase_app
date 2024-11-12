class Task {
  String id;
  String name;
  bool isCompleted;

  Task({required this.id, required this.name, this.isCompleted = false});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
      };

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      name: map['name'],
      isCompleted: map['isCompleted'],
    );
  }
}
