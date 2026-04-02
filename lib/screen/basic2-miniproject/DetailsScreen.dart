import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // 순서2, 로그인 화면에서, 전달한 데이터를 받기
    final args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('상세 화면')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(30.0),
              color: Colors.blue,
              child: Center(
                child: ListView(
                  children: [
                    Text(
                        args['title'],
                      style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      '임시 ID : ${args['id']} 번 데이터 정보 받기 '
                    ),
                    Text(
                        '임시 email : ${args['email']} '
                    ),
                    Text(
                        '임시 password : ${args['password']} '
                    ),  Text(
                        '임시 ID : ${args['id']} 번 데이터 정보 받기 '
                    ),
                    Text(
                        '임시 email : ${args['email']} '
                    ),
                    Text(
                        '임시 password : ${args['password']} '
                    ),  Text(
                        '임시 ID : ${args['id']} 번 데이터 정보 받기 '
                    ),
                    Text(
                        '임시 email : ${args['email']} '
                    ),
                    Text(
                        '임시 password : ${args['password']} '
                    ),
                  ],
                ),
              ),
            ),
            // 리스트 뷰 빌더 예시 복사
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return Card( // 카드 형태의 디자인 적용
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active, color: Colors.blue),
                      title: Text('[$index] Flutter 수업 안내'),
                      subtitle: const Text('내일은 리스트뷰 심화 과정입니다.'),
                      onTap: () {
                        // 클릭 시 피드백 알림
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$index번 공지를 확인했습니다.')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            //리스트 뷰 빌더 예시 복사

            // 리스트뷰 복사2
            Expanded(
              child: ListView.builder(
                itemCount: 20, // 총 20개의 아이템을 만들겠다!
                itemBuilder: (context, index) {
                  // index는 0부터 19까지 자동으로 증가합니다.
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('$index번 수강생님, 환영합니다!'),
                    subtitle: Text('오늘도 열공하세요.'),
                    trailing: Icon(Icons.check),
                  );
                },
              ),
            ),
            // 리스트뷰 복사2

            // 리스트뷰 복사3
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(title: Text('아이템 $index')),
                // 각 아이템 사이에 들어갈 위젯을 정해줍니다.
                separatorBuilder: (context, index) => const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
            ),
            // 리스트뷰 복사3

            Expanded(
              child: ListView(
                children: List.generate(
                  20,
                      (index) => ListTile(
                    leading: const FlutterLogo(),
                    title: Text('항목 $index'),
                    subtitle: const Text('상세 설명'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
