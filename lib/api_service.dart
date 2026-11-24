import 'dart:convert';

import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost/api-test/public',
);

class ApiService {
  ApiService({String baseUrl = apiBaseUrl, http.Client? client})
    : _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
      _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  Future<ApiAccount> login(String email, String password) async {
    final data = await _request(
      'POST',
      'accounts/login',
      body: {'email': email.trim(), 'password': password},
    );
    return ApiAccount.fromJson(data);
  }

  Future<ApiAccount> register(String email, String password) async {
    final data = await _request(
      'POST',
      'accounts/register',
      body: {'email': email.trim(), 'password': password},
    );
    return ApiAccount.fromJson(data);
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    final data = await _request('GET', 'famille-membres');
    if (data is! List) {
      throw const ApiException('Réponse invalide du serveur.');
    }
    return data
        .map((item) => FamilyMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FamilyMember> createFamilyMember(FamilyMemberPayload member) async {
    final data = await _request(
      'POST',
      'famille-membres',
      body: member.toJson(),
    );
    return FamilyMember.fromJson(data as Map<String, dynamic>);
  }

  Future<FamilyMember> updateFamilyMember(
    int id,
    FamilyMemberPayload member,
  ) async {
    final data = await _request(
      'PUT',
      'famille-membres/$id',
      body: member.toJson(),
    );
    return FamilyMember.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteFamilyMember(int id) async {
    await _request('DELETE', 'famille-membres/$id');
  }

  void close() => _client.close();

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = _baseUri.resolve(path);
    final headers = {'Accept': 'application/json'};
    final encodedBody = body == null ? null : jsonEncode(body);
    if (encodedBody != null) headers['Content-Type'] = 'application/json';

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(uri, headers: headers, body: encodedBody),
      'PUT' => await _client.put(uri, headers: headers, body: encodedBody),
      'DELETE' => await _client.delete(uri, headers: headers),
      _ => throw ArgumentError.value(method, 'method'),
    };

    dynamic envelope;
    try {
      envelope = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Réponse invalide du serveur (HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        envelope is! Map<String, dynamic> ||
        envelope['success'] != true) {
      final message = envelope is Map<String, dynamic>
          ? envelope['message'] as String?
          : null;
      final errors = envelope is Map<String, dynamic>
          ? envelope['errors'] as Map<String, dynamic>?
          : null;
      final details = errors?.values
          .map((value) => value.toString())
          .join('\n');
      throw ApiException(
        [
          message,
          details,
        ].whereType<String>().where((text) => text.isNotEmpty).join('\n'),
        statusCode: response.statusCode,
      );
    }

    return envelope['data'];
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiAccount {
  const ApiAccount({required this.id, required this.email});

  final int id;
  final String email;

  factory ApiAccount.fromJson(Map<String, dynamic> json) =>
      ApiAccount(id: json['id'] as int, email: json['email'] as String);
}

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  String get fullName => '$prenom $nom $postnom'.trim();

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: int.parse(json['id'].toString()),
    nom: json['nom'] as String,
    postnom: json['postnom'] as String,
    prenom: json['prenom'] as String,
    lieuNaissance: json['lieu_naissance'] as String,
    dateNaissance: json['date_naissance'] as String,
    parente: json['parente'] as String,
    imageUrl: json['image_url'] as String?,
  );
}

class FamilyMemberPayload {
  const FamilyMemberPayload({
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
  });

  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;

  Map<String, String> toJson() => {
    'nom': nom,
    'postnom': postnom,
    'prenom': prenom,
    'lieu_naissance': lieuNaissance,
    'date_naissance': dateNaissance,
    'parente': parente,
  };
}
