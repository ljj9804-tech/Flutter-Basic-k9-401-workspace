import 'package:busanit_401_k9_flutter_project/screen/basic2-miniproject/RoutingScreen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic4-provider/providers/CounterProvider.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic5-provider-pdData/_1_FoodData/controller/food_controller.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic5-provider-pdData/_2_TourData/controller/tour_controller.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic5-provider-pdData/_3_TourData_Pagination_Cursor_Based/controller/tour_controller.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic6-map/basic1-provider-version/providers/location_provider.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic6-map/basic2-googlePlaces-Provider/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_4_초기메인_백업용-스테이트풀용-동적화면.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ 추가

// void main() {
// ✅ void → Future<void> 로 변경
Future<void> main() async {
  // ✅ 비동기 작업 전 반드시 호출
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ .env 파일 로드 (runApp 전에 실행)
  await dotenv.load(fileName: '.env');

  // // 아래에 있는 미니 프로젝트 화면. -> 파일 분리
  // runApp(const RoutingScreen());

  // //프로바이더 패턴1, 단일프로바이더
  // runApp(
  //   // ChangeNotifierProvider: 위젯 트리 전체에 상태 공급
  //   // create: Provider 인스턴스 생성
  //   ChangeNotifierProvider(
  //     create: (_) => CounterProvider(),
  //     child: const RoutingScreen(),
  //   ),
  // );

  //프로바이더 패턴2, 멀티프로바이더
  runApp(
    // MultiProvider: 여러 개의 Provider를 한 번에 등록
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => FoodController()),
        // 공공데이터, 부산명소 , 상태 클래스 등록
        ChangeNotifierProvider(create: (_) => TourController()),
        ChangeNotifierProvider(create: (_) => TourController2()),
        //위치기반 서비스 1
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        //위치기반 서비스 2
        ChangeNotifierProvider(create: (_) => MapProvider()),

      ],
      child: const RoutingScreen(),
    ),
  );



  // 플러터를 최초에 실행시, 만들어준 화면,
  // 스테이트풀 설명하기에 가장 간단한 위젯.
  // runApp(const MyAppStart());


  // 기본 화면 위젯 알아보는 용도
  // runApp(const MyAppTest());
}



