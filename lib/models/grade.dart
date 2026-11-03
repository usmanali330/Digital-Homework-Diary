class Grade {
  final int? id;
  final String name;

  Grade({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      name: map['name'],
    );
  }

  Grade copyWith({int? id, String? name}) {
    return Grade(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
