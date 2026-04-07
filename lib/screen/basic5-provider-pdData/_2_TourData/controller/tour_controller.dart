import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/tour_item.dart';


class TourController with ChangeNotifier {
  final List<TourItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;   // ⭐ 연동1 대비 추가: 에러 메시지 상태

  List<TourItem>  get items        => _items;
  bool            get isLoading    => _isLoading;
  String?         get errorMessage => _errorMessage;

  Future<void> fetchTourData() async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final queryParams = {
      // 'serviceKey': '본인키', // ⚠️ 본인 인증키 입력
      'serviceKey':  dotenv.env['PUBLIC_DATA_SERVICE_KEY'] ?? '',
      'pageNo':    '1',
      'numOfRows': '100',
      'resultType': 'json',
    };

    // ✅ 맛집 API와 경로만 다름: AttractionService/getAttractionKr
    final uri = Uri.https(
      'apis.data.go.kr',
      // 틀린 예시
      // '/6260000/TourService/getTourKr',
      '/6260000/AttractionService/getAttractionKr', // 명세서의 Call Back URL 경로
      queryParams,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // ✅ 한글 깨짐 방지: bodyBytes + utf8.decode
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        // final dynamic tourData = decoded['getTourKr'];
        final dynamic tourData = decoded['getAttractionKr'];

        if (tourData is Map<String, dynamic> && tourData['item'] is List) {
          final List<dynamic> itemList = tourData['item'];
          _items.clear();
          _items.addAll(itemList.map((e) => TourItem.fromJson(e)).toList());
        } else {
          _errorMessage = '응답 데이터 구조가 예상과 다릅니다.';
          debugPrint('예상 외 구조: ${jsonEncode(tourData)}');
        }
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('데이터 로딩 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}