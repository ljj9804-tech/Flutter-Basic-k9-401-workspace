import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/food_item.dart';


class FoodController with ChangeNotifier {
  final List<FoodItem> _items = [];
  bool _isLoading = false;

  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchFoodData() async {
    _isLoading = true;
    notifyListeners(); // UI에 로딩 시작 알림

    final queryParams = {
      // 'serviceKey': '본인키',
      'serviceKey':  dotenv.env['PUBLIC_DATA_SERVICE_KEY'] ?? '',
      'pageNo': '1',
      'numOfRows': '100',
      'resultType': 'json',
    };

    final uri = Uri.https(
      'apis.data.go.kr',
      '/6260000/FoodService/getFoodKr',
      queryParams,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // ⚠️ response.body 대신 bodyBytes 사용 → 한글 인코딩 오류 방지
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final dynamic foodData = decoded['getFoodKr'];

        if (foodData is Map<String, dynamic> && foodData['item'] is List) {
          final List<dynamic> itemList = foodData['item'];
          _items.clear();
          _items.addAll(itemList.map((e) => FoodItem.fromJson(e)).toList());
        }
      }
    } catch (e) {
      debugPrint('데이터 로딩 실패: $e');
    }

    _isLoading = false;
    notifyListeners(); // UI에 데이터 완료 알림
  }
}