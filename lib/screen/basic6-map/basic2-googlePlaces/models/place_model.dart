// 주변 장소 모델 (Google Places API 응답 기준)
class PlaceModel {
  final String placeId;    // 장소 고유 ID
  final String name;       // 장소 이름
  final double lat;        // 위도
  final double lng;        // 경도
  final String? vicinity;  // 주소 (vicinity)
  final double? rating;    // 평점
  final String? type;      // 장소 유형

  PlaceModel({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    this.vicinity,
    this.rating,
    this.type,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    final types = (json['types'] as List<dynamic>?);
    return PlaceModel(
      placeId:  json['place_id'] as String,
      name:     json['name'] as String,
      lat:      (geometry['lat'] as num).toDouble(),
      lng:      (geometry['lng'] as num).toDouble(),
      vicinity: json['vicinity'] as String?,
      rating:   (json['rating'] as num?)?.toDouble(),
      type:     types?.isNotEmpty == true ? types!.first as String : null,
    );
  }
}