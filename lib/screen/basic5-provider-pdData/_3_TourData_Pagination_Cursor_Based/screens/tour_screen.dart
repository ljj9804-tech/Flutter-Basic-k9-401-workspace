
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tour_detail_screen.dart';
import '../controller/tour_controller.dart';


// ✅ 1. 화면 진입 시 한 번만 API를 호출하기 위해 StatefulWidget으로 변경합니다.
class TourScreen2 extends StatefulWidget {
  const TourScreen2({super.key});

  @override
  State<TourScreen2> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen2> {

  @override
  void initState() {
    super.initState();
    // ✅ 2. 화면이 그려진 직후(post-frame)에 딱 한 번만 데이터를 요청합니다.
    // main.dart의 MultiProvider에 등록된 전역 TourController 객체를 가져다 사용합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TourController>().fetchTourData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 3. 기존에 화면 전체를 감싸고 있던 ChangeNotifierProvider(create: ...) 껍데기를 삭제했습니다.
    // 삭제하지 않으면 전역 상태와 분리된 텅 빈 새 객체가 만들어져 버립니다.
    return Scaffold(
      appBar: AppBar(title: const Text('부산 관광지 정보')),

      // ✅ 4. 데이터 조회(UI 갱신)는 Consumer를 통해 안전하게 수행합니다.
      body: Consumer<TourController>(
        builder: (context, controller, _) {

          // 상태 1: 로딩 중
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 상태 2: 에러 발생 ⭐ 연동1에 없던 에러 처리
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
                    // ✅ 에러 시 재요청: 버튼 클릭 등 일회성 이벤트이므로 read 또는 controller 직접 사용
                    onPressed: () => context.read<TourController>().fetchTourData(),
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
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6,
                ),
                //추가
                clipBehavior: Clip.antiAlias, // 👈 InkWell 물결 효과가 둥근 모서리에 맞춰지도록 추가
                //추가, child 부분 감싸기.
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TourDetailScreen(item: item),
                      ),
                    );
                  },
                  //추가
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 관광지 이미지
                      if (item.image != null)
                      //추가
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
                            // 관광지명
                            Text(
                              item.mainTitle ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // 부제목
                            if (item.subTitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.subTitle!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                            // 주소 ⭐
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