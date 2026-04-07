import 'package:flutter/material.dart';
import '../model/tour_item.dart'; // 모델 경로에 맞게 수정하세요.

class TourDetailScreen extends StatelessWidget {
  final TourItem item;

  const TourDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.mainTitle ?? '관광지 상세정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 관광지 이미지 (Hero 애니메이션 적용)
            if (item.image != null && item.image!.isNotEmpty)
              Hero(
                tag: 'tour_image_${item.mainTitle}',
                child: Image.network(
                  item.image!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 250,
                    child: Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. 관광지명
                  Text(
                    item.mainTitle ?? '이름 없음',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 3. 부제목
                  if (item.subTitle != null && item.subTitle!.isNotEmpty)
                    Text(
                      item.subTitle!,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),

                  // 4. 주소
                  if (item.addr1 != null && item.addr1!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.addr1!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                  const Divider(height: 40, thickness: 1),

                  // 5. 관광지 소개 내용 (itemcntnts)
                  const Text(
                    '상세 설명',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.itemcntnts ?? '상세 설명이 제공되지 않습니다.',
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}