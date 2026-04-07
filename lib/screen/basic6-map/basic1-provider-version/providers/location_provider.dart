import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

/// 위치 상태를 관리하는 Provider
/// ChangeNotifier를 상속하여 상태 변경 시 UI에 자동으로 알림
class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;     // 현재 위치
  bool _isLoading = false;        // 로딩 상태
  String? _errorMessage;          // 오류 메시지
  bool _isTracking = false;       // 실시간 추적 여부
  StreamSubscription<Position>? _positionSub;
  final List<Position> _positionHistory = []; // 위치 히스토리

  // ── Getters (읽기 전용 외부 노출) ──────────────────────────
  Position? get currentPosition  => _currentPosition;
  bool      get isLoading        => _isLoading;
  String?   get errorMessage     => _errorMessage;
  bool      get isTracking       => _isTracking;
  List<Position> get positionHistory => List.unmodifiable(_positionHistory);
  double?   get latitude         => _currentPosition?.latitude;
  double?   get longitude        => _currentPosition?.longitude;

  /// 현재 위치 1회 가져오기
  Future<void> fetchCurrentLocation() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final pos = await LocationService.getCurrentPosition();
      _currentPosition = pos;
      _positionHistory.add(pos);
      notifyListeners(); // UI에 변경 알림
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 실시간 위치 추적 시작
  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _errorMessage = null;
    notifyListeners();

    _positionSub = LocationService.getPositionStream().listen(
          (Position pos) {
        _currentPosition = pos;
        _positionHistory.add(pos);
        notifyListeners(); // 위치 변경 시마다 UI 갱신
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isTracking = false;
        notifyListeners();
      },
    );
  }

  /// 실시간 위치 추적 종료
  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _isTracking = false;
    notifyListeners();
  }

  /// 위치 히스토리 초기화
  void clearHistory() {
    _positionHistory.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel(); // 리소스 해제 (메모리 누수 방지)
    super.dispose();
  }
}