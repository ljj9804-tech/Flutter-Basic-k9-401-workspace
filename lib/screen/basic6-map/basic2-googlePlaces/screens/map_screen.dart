import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 구글 지도 위젯 및 컨트롤러
import 'package:geolocator/geolocator.dart'; // GPS 위치 데이터 모델
import '../models/place_model.dart'; // 검색된 장소 데이터 모델
import '../services/location_service.dart'; // 위치 권한 및 스트림 서비스
import '../services/places_service.dart'; // Google Places API 호출 서비스

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ---------------------------------------------------------
  // 1. 상태 관리 변수들
  // ---------------------------------------------------------
  GoogleMapController? _mapController;     // 지도를 프로그램적으로 제어(카메라 이동 등)
  Position? _currentPosition;              // 사용자의 최신 위도/경도 정보 저장
  final Set<Marker> _markers = {};         // 지도에 표시될 마커들의 집합 (중복 방지 Set)
  final List<LatLng> _routePoints = [];    // 실시간 이동 시 그려질 선(Polyline)의 좌표들
  StreamSubscription<Position>? _positionSub; // 위치 변경 감지 리스너를 해제하기 위한 구독 객체
  bool _isTracking = false;                // 실시간 위치 추적 활성화 상태 플래그
  bool _isLoading = true;                  // 초기 위치 로딩 상태
  String _selectedType = 'restaurant';     // 현재 선택된 주변 장소 검색 카테고리

  // 검색 가능한 장소 유형 정의 (UI 칩 생성용)
  static const List<Map<String, String>> _placeTypes = [
    {'key': 'restaurant', 'label': '음식점', 'icon': '🍽️'},
    {'key': 'cafe',       'label': '카페',   'icon': '☕'},
    {'key': 'hospital',   'label': '병원',   'icon': '🏥'},
    {'key': 'school',     'label': '학교',   'icon': '🏫'},
    {'key': 'bank',       'label': '은행',   'icon': '🏦'},
  ];

  @override
  void initState() {
    super.initState();
    _initLocation(); // 앱 시작 시 현재 위치 초기화
  }

  @override
  void dispose() {
    // 🔴 중요: 메모리 누수 방지를 위해 컨트롤러와 구독을 반드시 해제
    _positionSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // 2. 위치 및 카메라 제어 메서드
  // ---------------------------------------------------------

  // 초기 위치 설정: 앱 실행 시 1회 호출
  Future<void> _initLocation() async {
    try {
      // 서비스에서 현재 위치(1회성)를 가져옴
      final pos = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
        _isLoading = false;
      });
      _addMyMarker(pos); // 지도에 파란색 내 위치 마커 표시
      _moveCamera(pos);  // 해당 위치로 지도 시점 이동
      await _searchNearby(); // 내 주변 장소(기본값: 음식점) 검색 시작
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('위치 오류: $e');
    }
  }

  // 내 위치 마커 생성 및 갱신
  void _addMyMarker(Position pos) {
    final myMarker = Marker(
      markerId: const MarkerId('my_location'), // ID가 같으면 기존 마커를 덮어씀
      position: LatLng(pos.latitude, pos.longitude),
      infoWindow: const InfoWindow(title: '내 위치'),
      // 파란색 마커로 설정 (기본은 빨간색)
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    setState(() {
      // 기존 내 위치 마커를 지우고 새 위치 마커 추가
      _markers.removeWhere((m) => m.markerId.value == 'my_location');
      _markers.add(myMarker);
    });
  }

  // 카메라 이동 애니메이션
  void _moveCamera(Position pos) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 15.0, // 숫자가 클수록 확대 (기본 15가 적당함)
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 3. 주변 장소 검색 및 마커 표시 로직
  // ---------------------------------------------------------

  // API를 통해 주변 장소 데이터를 가져옴
  Future<void> _searchNearby() async {
    if (_currentPosition == null) return;
    try {
      final places = await PlacesService.searchNearby(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        radius: 1000, // 반경 1km 이내 검색
        type: _selectedType, // 선택된 카테고리 (음식점, 카페 등)
      );
      _addPlaceMarkers(places); // 검색된 결과들을 마커로 변환
    } catch (e) {
      _showSnackBar('장소 검색 실패: $e');
    }
  }

  // 검색된 장소들을 지도 마커로 추가
  void _addPlaceMarkers(List<PlaceModel> places) {
    setState(() {
      // 🔴 내 위치 마커('my_location')만 남기고 나머지는 모두 제거 (청소)
      _markers.removeWhere((m) => m.markerId.value != 'my_location');
    });

    for (final place in places) {
      final marker = Marker(
        markerId: MarkerId(place.placeId),
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(
          title: place.name,
          // 평점이 있으면 평점 표시, 없으면 주소(vicinity)만 표시
          snippet: place.rating != null
              ? '⭐ ${place.rating!.toStringAsFixed(1)} | ${place.vicinity ?? ''}'
              : place.vicinity,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      setState(() => _markers.add(marker));
    }
    _showSnackBar('${places.length}개 장소를 찾았습니다.');
  }

  // ---------------------------------------------------------
  // 4. 실시간 위치 추적 (Tracking) 로직
  // ---------------------------------------------------------

  // 상단 아이콘 클릭 시 추적 시작/중료
  void _toggleTracking() {
    if (_isTracking) {
      // [상태 1] 추적 중일 때 누르면 -> 추적 종료
      _positionSub?.cancel(); // 리스너 해제
      setState(() => _isTracking = false);
      _showSnackBar('위치 추적을 종료했습니다.');
    } else {
      // [상태 2] 추적 중이 아닐 때 누르면 -> 추적 시작
      setState(() {
        _isTracking = true;
        _routePoints.clear(); // 이전 이동 경로 선 지우기
      });

      // 위치 서비스의 Stream(흐름)을 구독하여 실시간 데이터 수신
      _positionSub = LocationService.getPositionStream().listen(
            (Position pos) {
          setState(() {
            _currentPosition = pos;
            // 이동한 궤적을 리스트에 추가하여 선(Polyline)을 그림
            _routePoints.add(LatLng(pos.latitude, pos.longitude));
          });
          _addMyMarker(pos); // 움직이는 내 위치 마커 갱신
          _moveCamera(pos);  // 카메라가 자동으로 나를 따라옴
        },
        onError: (e) {
          _showSnackBar('추적 오류: $e');
          setState(() => _isTracking = false);
        },
      );
      _showSnackBar('실시간 위치 추적을 시작합니다.');
    }
  }

  // 공통 안내 메시지 (스낵바)
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ---------------------------------------------------------
  // 5. UI 렌더링 (Build)
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ 지도 & 위치 추적'),
        actions: [
          IconButton(
            icon: Icon(
              _isTracking ? Icons.location_searching : Icons.location_disabled,
              color: _isTracking ? Colors.red : null,
            ),
            tooltip: _isTracking ? '추적 종료' : '실시간 추적',
            onPressed: _toggleTracking,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시
          : Column(
        children: [
          // [상단] 장소 유형 선택 칩 리스트 (수평 스크롤)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _placeTypes.length,
              itemBuilder: (context, index) {
                final type = _placeTypes[index];
                final isSelected = _selectedType == type['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${type['icon']} ${type['label']}'),
                    selected: isSelected,
                    onSelected: (_) async {
                      setState(() => _selectedType = type['key']!);
                      await _searchNearby(); // 카테고리 바꾸면 즉시 재검색
                    },
                  ),
                );
              },
            ),
          ),

          // [중앙] 구글 지도 표시 영역
          Expanded(
            child: GoogleMap(
              // 초기 화면 위치 설정 (현재 위치가 없으면 부산 기본값)
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(35.1795, 129.0756),
                zoom: 15.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller; // 지도 생성 시 컨트롤러 할당
              },
              myLocationEnabled: true,         // 내 위치 파란 점 활성화 (OS 기본 기능)
              myLocationButtonEnabled: true,   // 내 위치로 돌아오는 버튼 표시
              markers: _markers,               // 생성한 마커들 표시
              // 폴리라인: 이동 경로를 선으로 연결
              polylines: _routePoints.length > 1
                  ? {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _routePoints,
                  color: Colors.blue,
                  width: 4,
                ),
              }
                  : {},
              mapType: MapType.normal,         // 지도 스타일 (일반, 위성, 하이브리드 등)
            ),
          ),
        ],
      ),

      // 주변 검색 재실행 플로팅 버튼
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150.0),
        child: FloatingActionButton(
          onPressed: _searchNearby,
          tooltip: '주변 검색',
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}