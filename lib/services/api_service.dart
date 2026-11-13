
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client})
      : _client = client ?? http.Client();

  // GET /companies
  Future<List<dynamic>> getCompanies() async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.companiesEndpoint}',
      ),
    );

    final body = _decodeResponse(response);

    return body['data'] as List<dynamic>;
  }

  // POST /companies
  Future<Map<String, dynamic>> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.companiesEndpoint}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'registrationNumber': registrationNumber,
      }),
    );

    return _decodeResponse(response);
  }

  // POST /services
  Future<Map<String, dynamic>> createService({
    required int companyId,
    required String name,
    String? description,
    required double price,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.servicesEndpoint}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'companyId': companyId,
        'name': name,
        'description': description,
        'price': price,
      }),
    );

    return _decodeResponse(response);
  }

  // Handle API responses and errors
  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid server response.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw Exception(
      decoded['message'] ?? 'Request failed (${response.statusCode}).',
    );
  }

  void dispose() {
    _client.close();
  }
}
