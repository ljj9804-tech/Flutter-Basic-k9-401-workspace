import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 현재 위치를 가져오는 메서드 (1회성)
  /// - 권한 확인 → 권한 요청 → 위치 반환
  static Future<Position> getCurrentPosition() async {
    // 1. 위치 서비스 활성화 여부 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 활성화해주세요.');
    }

    // 2. 위치 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. 권한이 거부된 경우 요청
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    // 4. 영구 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.');
    }

    // 5. 위치 정보 반환 (정확도: high)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// 🔴 [여기에 추가됨] 실시간 위치 정보를 가져오는 스트림 반환
  static Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 5미터 이동할 때마다 갱신
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 두 지점 간의 거리 계산 (미터 단위)
  static double calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}