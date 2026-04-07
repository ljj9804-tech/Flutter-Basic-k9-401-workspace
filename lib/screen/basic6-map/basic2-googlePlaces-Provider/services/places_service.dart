import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';

// 추가
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  // 추가
  static String get _apiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // static const String _apiKey = '본인키';
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  /// 주변 장소 검색
  /// [lat], [lng]: 검색 중심 좌표
  /// [radius]: 검색 반경 (미터, 최대 50000)
  /// [type]: 장소 유형 (restaurant, cafe, hospital, school 등)
  static Future<List<PlaceModel>> searchNearby({
    required double lat,
    required double lng,
    int radius = 1000,
    String type = 'restaurant',
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'type': type,
        'language': 'ko',     // 한국어 결과
        'key': _apiKey,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))
      as Map<String, dynamic>;

      final status = data['status'] as String;
      if (status == 'ZERO_RESULTS') return [];
      if (status != 'OK') throw Exception('Places API 오류: $status');

      final results = data['results'] as List<dynamic>;
      return results
          .map((r) => PlaceModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('HTTP 오류: ${response.statusCode}');
    }
  }
}