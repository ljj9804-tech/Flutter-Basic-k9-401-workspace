import 'package:busanit_401_k9_flutter_project/screen/basic2-miniproject/TabBarScreen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic3-http/_1_dummyJson/screens/dummy_user_detail_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic3-http/_3_news_api/screens/news_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic3-http/_4_public_data_1_earthquake/screens/PublicDataScreen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic4-provider/screens/CounterScreen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic5-provider-pdData/_1_FoodData/screens/my_pd_test_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic5-provider-pdData/_2_TourData/screens/tour_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic5-provider-pdData/_3_TourData_Pagination_Cursor_Based/screens/tour_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic6-map/basic1-provider-version/screens/location_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic6-map/basic1/screens/location_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic6-map/basic2-googlePlaces-Provider/screens/map_screen.dart';
import 'package:busanit_401_k9_flutter_project/screen/basic6-map/basic2-googlePlaces/screens/map_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../basic3-http/_1_dummyJson/screens/dummy_user_screen.dart';
import '../basic3-http/_2_reqres/screen/reqres_screen.dart';
import 'AccordionNavScreen.dart';
import 'DetailsScreen.dart';
import 'LoginScreen2.dart';
import 'MainScreen.dart';
import 'SignupScreen.dart';
import 'SplashScreen.dart';
import 'ViewPagerScreen.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/main':    (context) => const MainScreen(),
        '/signup':  (context) => const SignupScreen(),
        '/login':   (context) => const LoginScreen2(),
        '/details': (context) => const DetailsScreen(),
        // 탭 메뉴 화면 추가.
        '/tabMenuTest': (context) => const TabBarScreen(),
        '/viewPagerTest': (context) => const PageViewScreen(),
        '/drawerNaviTest': (context) => const AccordionNavScreen(),
        // API 서버 호출 테스트
        '/reqresTest': (context) => const ReqresScreen(),
        '/dummyTest': (context) => const DummyUserScreen(),
        // 상세 화면 이동 라우팅 추가, /dummyDetailScreen -> 파라미터 , 유저 정보를 주입해야해서,
        // '/dummyDetailScreen': (context) => const DummyUserDetailScreen(user: user),
        '/newsTest': (context) => const NewsScreen(),
        '/publicDataTest': (context) => const PublicDataScreen(),
        '/providerTest': (context) => const CounterScreen(),
        '/providerTestPdTest': (context) => const MyPdTestScreen(),
        '/providerTestPdTest2': (context) => const TourScreen(),
        '/providerTestPdTest3': (context) => const TourScreen2(),
        '/mapBasic1': (context) => const LocationScreen(),
        '/mapBasic2': (context) => const LocationScreen2(),
        '/mapBasic3': (context) => const MapScreen(),
        '/mapBasic4': (context) => const MapScreen2(),


      },
    );
  }
}