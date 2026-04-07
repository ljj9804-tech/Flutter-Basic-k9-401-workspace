import 'tour_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/tour_controller.dart';

class TourScreen2 extends StatefulWidget {
  const TourScreen2({super.key});

  @override
  State<TourScreen2> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen2> {

  // 🔴 [무한 스크롤 추가 1] 스크롤 위치를 감지하는 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔴 [변경됨] fetchTourData() -> fetchInitial()로 변경 (1페이지부터 로딩)
      context.read<TourController2>().fetchInitial();
    });

    // 🔴 [무한 스크롤 추가 2] 스크롤 끝 감지 리스너 등록
    _scrollController.addListener(_onScroll);
  }

  // 🔴 [무한 스크롤 추가 3] 스크롤 위치를 감지하여 다음 페이지를 요청하는 메서드
  void _onScroll() {
    final position = _scrollController.position;
    // 스크롤이 맨 끝에서 200px 이내에 도달하면 다음 페이지 요청
    final isNearEnd = position.pixels >= position.maxScrollExtent - 200;

    if (isNearEnd) {
      context.read<TourController2>().fetchMore();
    }
  }

  // 🔴 [무한 스크롤 추가 4] 컨트롤러 메모리 해제
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('부산 관광지 정보')),
      body: Consumer<TourController2>(
        builder: (context, controller, _) {

          // 상태 1: 로딩 중
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 상태 2: 에러 발생
          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    // 🔴 [변경됨] 에러 시 다시 1페이지부터 시도하도록 수정
                    onPressed: () => context.read<TourController2>().fetchInitial(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 상태 3: 데이터 없음
          if (controller.items.isEmpty) {
            return const Center(child: Text('관광지 데이터가 없습니다.'));
          }

          // 상태 4: 데이터 표시
          return ListView.builder(
            // 🔴 [무한 스크롤 추가 5] 리스트뷰에 스크롤 컨트롤러 연결
            controller: _scrollController,

            // 🔴 [무한 스크롤 추가 6] 실제 데이터 수 + 맨 밑 로딩 인디케이터 1칸
            itemCount: controller.items.length + 1,

            itemBuilder: (context, index) {

              // 🔴 [무한 스크롤 추가 7] 마지막 인덱스일 때 로딩 바 또는 완료 메시지 표시
              if (index == controller.items.length) {
                if (controller.isFetchingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!controller.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '모든 관광지를 불러왔습니다 ✅',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              // ==============================================================
              // 🔵 [상세페이지 이동 유지] 아래부터는 기존 2번 코드와 100% 동일합니다.
              // ==============================================================
              final item = controller.items[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TourDetailScreen(item: item),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.image != null)
                        Hero(
                          tag: 'tour_image_${item.mainTitle}',
                          child: Image.network(
                            item.image!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const SizedBox(height: 180,
                              child: Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.mainTitle ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.subTitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.subTitle!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                            if (item.addr1 != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 14, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.addr1!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}