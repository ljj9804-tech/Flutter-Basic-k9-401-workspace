import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place_model.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

/// 지도 화면 전체 상태를 관리하는 Provider
class MapProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  Position? _currentPosition;             // 현재 GPS 위치
  final Set<Marker> _markers = {};        // 지도 마커
  final List<LatLng> _routePoints = [];   // 이동 경로 좌표
  bool _isTracking = false;               // 실시간 추적 여부
  bool _isLoading = false;                // 초기 로딩
  bool _isSearching = false;              // 장소 검색 중
  String? _errorMessage;                  // 오류 메시지
  String _selectedType = 'restaurant';    // 선택된 장소 유형
  List<PlaceModel> _nearbyPlaces = [];    // 검색된 장소 목록
  StreamSubscription<Position>? _positionSub;

  // ── Getters ──────────────────────────────────────────
  Position?         get currentPosition => _currentPosition;
  Set<Marker>       get markers         => Set.unmodifiable(_markers);
  List<LatLng>      get routePoints     => List.unmodifiable(_routePoints);
  bool              get isTracking      => _isTracking;
  bool              get isLoading       => _isLoading;
  bool              get isSearching     => _isSearching;
  String?           get errorMessage    => _errorMessage;
  String            get selectedType    => _selectedType;
  List<PlaceModel>  get nearbyPlaces    => List.unmodifiable(_nearbyPlaces);

  /// GoogleMapController 등록 (onMapCreated 콜백)
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// 앱 시작 시 위치 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final pos = await LocationService.getCurrentPosition();
      _currentPosition = pos;
      _addMyMarker(pos);
      _moveCamera(pos);
      await searchNearby(); // 초기 주변 검색
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 장소 유형 변경
  void setPlaceType(String type) {
    _selectedType = type;
    notifyListeners();
    searchNearby();
  }

  /// 주변 장소 검색
  Future<void> searchNearby() async {
    if (_currentPosition == null) return;
    _isSearching = true;
    notifyListeners();
    try {
      final places = await PlacesService.searchNearby(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        type: _selectedType,
      );
      _nearbyPlaces = places;
      _updatePlaceMarkers(places);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// 실시간 추적 시작/종료
  void toggleTracking() {
    _isTracking ? _stopTracking() : _startTracking();
  }

  void _startTracking() {
    _isTracking = true;
    _routePoints.clear();
    notifyListeners();

    _positionSub = LocationService.getPositionStream().listen(
          (Position pos) {
        _currentPosition = pos;
        _routePoints.add(LatLng(pos.latitude, pos.longitude));
        _addMyMarker(pos);
        _moveCamera(pos);
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isTracking = false;
        notifyListeners();
      },
    );
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  void _addMyMarker(Position pos) {
    final myMarker = Marker(
      markerId: const MarkerId('my_location'),
      position: LatLng(pos.latitude, pos.longitude),
      infoWindow: const InfoWindow(title: '내 위치'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    _markers.removeWhere((m) => m.markerId.value == 'my_location');
    _markers.add(myMarker);
  }

  void _updatePlaceMarkers(List<PlaceModel> places) {
    _markers.removeWhere((m) => m.markerId.value != 'my_location');
    for (final place in places) {
      _markers.add(Marker(
        markerId: MarkerId(place.placeId),
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.rating != null
              ? '⭐ ${place.rating!.toStringAsFixed(1)} | ${place.vicinity ?? ''}'
              : place.vicinity,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
  }

  void _moveCamera(Position pos) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}