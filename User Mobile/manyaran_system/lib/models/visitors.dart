// To parse this JSON data, do
//
//     final visitors = visitorsFromJson(jsonString);

import 'dart:convert';

Map<String, Visitors> visitorsFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, Visitors>(k, Visitors.fromJson(v)));

String visitorsToJson(Map<String, Visitors> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class Visitors {
  Visitors({
    required this.date,
  });

  final int date;

  factory Visitors.fromJson(Map<String, dynamic> json) => Visitors(
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
  };
}
