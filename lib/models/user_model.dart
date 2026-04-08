import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String studentId;
  final String? avatarUrl;
  final String? phone;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.studentId,
    this.avatarUrl,
    this.phone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        studentId: json['student_id'] as String,
        avatarUrl: json['avatar_url'] as String?,
        phone: json['phone'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'student_id': studentId,
        'avatar_url': avatarUrl,
        'phone': phone,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? studentId,
    String? avatarUrl,
    String? phone,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        studentId: studentId ?? this.studentId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
      );

  String get firstName => fullName.split(' ').first;

  @override
  List<Object?> get props =>
      [id, fullName, email, studentId, avatarUrl, phone, createdAt];
}
