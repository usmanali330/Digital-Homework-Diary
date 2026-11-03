import 'package:flutter/material.dart';

class Subject {
  final int? id;
  final String name;
  final String colorCode;

  Subject({this.id, required this.name, required this.colorCode});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_code': colorCode,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      colorCode: map['color_code'],
    );
  }

  Subject copyWith({int? id, String? name, String? colorCode}) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  Color get color {
    final hexString = colorCode.replaceAll('#', '');
    return Color(int.parse('FF$hexString', radix: 16));
  }
}
