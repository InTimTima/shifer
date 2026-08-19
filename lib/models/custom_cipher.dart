import 'dart:convert';

class CustomCipherDef {
  final String id;
  final String name;
  final String baseAlphabetId;
  final String cipherLetters;
  final String description;

  const CustomCipherDef({
    required this.id,
    required this.name,
    required this.baseAlphabetId,
    required this.cipherLetters,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseAlphabetId': baseAlphabetId,
        'cipherLetters': cipherLetters,
        'description': description,
      };

  factory CustomCipherDef.fromJson(Map<String, dynamic> json) =>
      CustomCipherDef(
        id: json['id'] as String,
        name: json['name'] as String,
        baseAlphabetId: json['baseAlphabetId'] as String,
        cipherLetters: json['cipherLetters'] as String,
        description: json['description'] as String? ?? '',
      );

  String toJsonString() => jsonEncode(toJson());

  factory CustomCipherDef.fromJsonString(String raw) =>
      CustomCipherDef.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
