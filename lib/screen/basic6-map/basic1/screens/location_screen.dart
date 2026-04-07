import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition; // 현재 위치
  bool _isLoading = false;    // 로딩 상태
  String? _errorMessage;      // 오류 메시지

  @override
  void initState() {
    super.initState();
    _fetchLocation(); // 화면 진입 시 위치 가져오기
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 현재 위치'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocation,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('위치를 가져오는 중...'),
          ],
        )
            : _errorMessage != null
            ? _buildErrorWidget()
            : _currentPosition != null
            ? _buildLocationInfo()
            : const Text('위치 정보가 없습니다.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchLocation,
        icon: const Icon(Icons.my_location),
        label: const Text('위치 갱신'),
      ),
    );
  }

  // 위치 정보 표시 위젯
  Widget _buildLocationInfo() {
    final pos = _currentPosition!;
    // 부산 시청 기준 거리 계산 예시
    final distanceToBusan = LocationService.calculateDistance(
      pos.latitude, pos.longitude,
      35.1795543, 129.0756416, // 부산 시청 좌표
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 위치 아이콘
          const Icon(Icons.location_on, size: 80, color: Colors.red),
          const SizedBox(height: 24),

          // 위도 카드
          _infoCard(
            icon: Icons.north,
            label: '위도 (Latitude)',
            value: pos.latitude.toStringAsFixed(6),
            color: Colors.blue,
          ),
          const SizedBox(height: 12),

          // 경도 카드
          _infoCard(
            icon: Icons.east,
            label: '경도 (Longitude)',
            value: pos.longitude.toStringAsFixed(6),
            color: Colors.green,
          ),
          const SizedBox(height: 12),

          // 고도 카드
          _infoCard(
            icon: Icons.terrain,
            label: '고도 (Altitude)',
            value: '${pos.altitude.toStringAsFixed(1)} m',
            color: Colors.brown,
          ),
          const SizedBox(height: 12),

          // 정확도 카드
          _infoCard(
            icon: Icons.gps_fixed,
            label: '정확도 (Accuracy)',
            value: '±${pos.accuracy.toStringAsFixed(1)} m',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),

          // 부산 시청까지 거리
          _infoCard(
            icon: Icons.directions_walk,
            label: '부산 시청까지 거리',
            value: distanceToBusan >= 1000
                ? '${(distanceToBusan / 1000).toStringAsFixed(2)} km'
                : '${distanceToBusan.toStringAsFixed(0)} m',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  // 정보 카드 위젯
  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // 오류 표시 위젯
  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchLocation,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: const Text('위치 설정 열기'),
          ),
        ],
      ),
    );
  }
}