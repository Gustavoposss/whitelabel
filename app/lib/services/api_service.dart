import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/client.dart';
import '../models/auth.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  final http.Client _client;
  String? _token;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Products
  Future<List<Product>> getProducts({
    String? name,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? provider,
  }) async {
    final queryParams = <String, String>{};
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (provider != null && provider.isNotEmpty) queryParams['provider'] = provider;

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<Product> getProductById(String id, {String? provider}) async {
    final queryParams = <String, String>{};
    if (provider != null && provider.isNotEmpty) queryParams['provider'] = provider;

    final uri = Uri.parse('$baseUrl/products/$id').replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }

  // Client
  Future<Client> getCurrentClient({String? clientUrl}) async {
    final headers = Map<String, String>.from(_headers);
    if (clientUrl != null && clientUrl.isNotEmpty) {
      headers['X-Client-URL'] = clientUrl;
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/clients/current'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load client: ${response.body}');
    }
  }
}

