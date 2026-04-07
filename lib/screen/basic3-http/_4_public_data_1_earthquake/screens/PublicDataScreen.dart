import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/EarthquakeInfo.dart';
import '../services/EarthquakeApiService.dart';

class PublicDataScreen extends StatefulWidget {
  const PublicDataScreen({super.key});

  @override
  State<PublicDataScreen> createState() => _PublicDataScreenState();
}

class _PublicDataScreenState extends State<PublicDataScreen> {
  late Future<List<EarthquakeInfo>> _earthquakeFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // API 형식(YYYYMMDDHHMI)에 맞게 날짜를 변환하는 함수
  String _formatDate(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}'
        '0000'; // 시간, 분은 0000으로 고정
  }

  // 최근 3일간의 데이터를 요청하도록 _loadData 수정
  void _loadData() {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    setState(() {
      _earthquakeFuture = EarthquakeApiService.fetchEarthquakes(
        // fromTmFc: _formatDate(threeDaysAgo),
        // toTmFc: _formatDate(now),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공공데이터 - 지진정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<List<EarthquakeInfo>>(
        future: _earthquakeFuture,
        builder: (context, snapshot) {
          // 1. 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. 에러 발생 (API DB_ERROR 포함)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('오류: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('재시도'),
                  ),
                ],
              ),
            );
          }

          // 3. 데이터 없음
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('조회된 지진 데이터가 없습니다.'));
          }

          // 4. 정상 출력
          final earthquakes = snapshot.data!;
          return ListView.builder(
            itemCount: earthquakes.length,
            itemBuilder: (context, index) {
              final eq = earthquakes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: eq.magnitude >= 3.0
                        ? Colors.red
                        : Colors.orange,
                    child: Text(
                      eq.magnitude.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(eq.location),
                  subtitle: Text(eq.originTime),
                  trailing: Text('진원: ${eq.depth}km'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}