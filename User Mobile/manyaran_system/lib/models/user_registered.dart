// To parse this JSON data, do
//
//     final userRegisteredModel = userRegisteredModelFromJson(jsonString);

import 'dart:convert';

Map<String, UserRegisteredModel> userRegisteredModelFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, UserRegisteredModel>(k, UserRegisteredModel.fromJson(v)));

String userRegisteredModelToJson(Map<String, UserRegisteredModel> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class UserRegisteredModel {
  UserRegisteredModel({
    this.idToken,
    this.access,
    this.createdDate,
    this.name,
    this.avatar,
    this.createdUnix,
    this.email,
  });

  final String idToken;
  final bool access;
  final String createdDate;
  final String name;
  final String avatar;
  final int createdUnix;
  final String email;

  factory UserRegisteredModel.fromJson(Map<String, dynamic> json) => UserRegisteredModel(
    access: json["access"],
    createdDate: json["createdDate"],
    name: json["name"],
    avatar: json["avatar"],
    createdUnix: json["createdUnix"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "access": access,
    "createdDate": createdDate,
    "name": name,
    "avatar": avatar,
    "createdUnix": createdUnix,
    "email": email,
  };
}
