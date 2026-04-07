import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메인 화면')),
      body: SafeArea(
        child: ListView(
          children: [
            // const Center(child: FlutterLogo(size: 100)),
            Center(
              // child: FlutterLogo(size: 100)
              child: Image.asset(
                'assets/images/logo2.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('회원 가입'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('로그인'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/tabMenuTest'),
              child: const Text('탭 메뉴 연습'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/viewPagerTest'),
              child: const Text('뷰페이져 연습'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/drawerNaviTest'),
              child: const Text('아코디언, 드로워, 네비게이션 연습'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/reqresTest'),
              child: const Text('_2_reqres 데이터 연동 테스트 '),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/dummyTest'),
              child: const Text('dummy 사이트 데이터 연동 테스트 '),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/newsTest'),
              child: const Text('newsTest 사이트 데이터 연동 테스트 '),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/publicDataTest'),
              child: const Text('publicDataTest 지진정보 공공데이터 연동 테스트 '),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/providerTest'),
              child: const Text('provider 테스트 1'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/providerTestPdTest'),
              child: const Text('provider 테스트 2, 공공데이터 음식'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/providerTestPdTest2'),
              child: const Text('provider 테스트 3, 공공데이터 부산관광명소'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/providerTestPdTest3'),
              child: const Text('커서기반 무한 스크롤페이지네이션 테스트 4, 공공데이터 부산관광명소'),
            ),

          ],
        ),
      ),
    );
  }

}
