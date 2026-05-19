import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String tokenKey = 'auth_token';

  static String get baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://127.0.0.1:8000/api');
}
