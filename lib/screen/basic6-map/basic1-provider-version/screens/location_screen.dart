import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';

class LocationScreen2 extends StatelessWidget {
  const LocationScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 현재 위치 (Provider)'),
        actions: [
          // Selector: isTracking 값이 바뀔 때만 이 버튼 리빌드
          Selector<LocationProvider, bool>(
            selector: (_, p) => p.isTracking,
            builder: (context, isTracking, _) {
              return IconButton(
                icon: Icon(
                  isTracking ? Icons.location_searching : Icons.location_off,
                  color: isTracking ? Colors.red : null,
                ),
                onPressed: () {
                  final p = context.read<LocationProvider>();
                  isTracking ? p.stopTracking() : p.startTracking();
                },
              );
            },
          ),
        ],
      ),
      // Consumer: Provider 상태 변경 시 body 전체 리빌드
      body: Consumer<LocationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('위치를 가져오는 중...'),
                ],
              ),
            );
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<LocationProvider>().fetchCurrentLocation(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                    ),
                    TextButton(
                      onPressed: () => Geolocator.openLocationSettings(),
                      child: const Text('위치 설정 열기'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (provider.currentPosition == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gps_not_fixed, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('위치 정보가 없습니다.'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<LocationProvider>().fetchCurrentLocation(),
                    icon: const Icon(Icons.my_location),
                    label: const Text('위치 가져오기'),
                  ),
                ],
              ),
            );
          }

          final pos = provider.currentPosition!;

          // 🔴 추가: 리스트를 최신순(역순)으로 보기 위해 뒤집습니다.
          final historyList = provider.positionHistory.reversed.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.isTracking)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                        SizedBox(width: 8),
                        Text('실시간 위치 추적 중...',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                _InfoCard(icon: Icons.north,    label: '위도 (Latitude)',   value: pos.latitude.toStringAsFixed(6),   color: Colors.blue),
                const SizedBox(height: 8),
                _InfoCard(icon: Icons.east,     label: '경도 (Longitude)',  value: pos.longitude.toStringAsFixed(6),  color: Colors.green),
                const SizedBox(height: 8),
                _InfoCard(icon: Icons.terrain,  label: '고도 (Altitude)',   value: '${pos.altitude.toStringAsFixed(1)} m', color: Colors.brown),
                const SizedBox(height: 8),
                _InfoCard(icon: Icons.gps_fixed, label: '정확도 (Accuracy)', value: '±${pos.accuracy.toStringAsFixed(1)} m', color: Colors.orange),
                const SizedBox(height: 8),
                _InfoCard(icon: Icons.history,  label: '측정 횟수',         value: '${provider.positionHistory.length}회', color: Colors.purple),

                const SizedBox(height: 24),

                // 🔴 여기서부터 기록 리스트 뷰 영역입니다.
                if (historyList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📝 이동 기록',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => context.read<LocationProvider>().clearHistory(),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('초기화'),
                      ),
                    ],
                  ),
                  const Divider(),
                  // SingleChildScrollView 내부에서 ListView를 쓰기 위한 설정
                  ListView.builder(
                    shrinkWrap: true, // 부모의 공간에 맞게 크기 축소
                    physics: const NeverScrollableScrollPhysics(), // 스크롤은 부모(SingleChildScrollView)에게 위임
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final historyPos = historyList[index];
                      // 시간 포맷팅 (시:분:초)
                      final timeStr = historyPos.timestamp != null
                          ? '${historyPos.timestamp!.hour.toString().padLeft(2, '0')}:${historyPos.timestamp!.minute.toString().padLeft(2, '0')}:${historyPos.timestamp!.second.toString().padLeft(2, '0')}'
                          : '시간 알 수 없음';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.purple.withValues(alpha: 0.1),
                            child: Text('${historyList.length - index}', style: const TextStyle(fontSize: 12)),
                          ),
                          title: Text('${historyPos.latitude.toStringAsFixed(5)}, ${historyPos.longitude.toStringAsFixed(5)}'),
                          subtitle: Text('오차 ±${historyPos.accuracy.toStringAsFixed(0)}m'),
                          trailing: Text(timeStr, style: const TextStyle(color: Colors.grey)),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<LocationProvider>().fetchCurrentLocation(),
        icon: const Icon(Icons.my_location),
        label: const Text('위치 갱신'),
      ),
    );
  }
}

// 재사용 가능한 정보 카드 위젯
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({required this.icon, required this.label,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1), // 🔴 변경됨
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}