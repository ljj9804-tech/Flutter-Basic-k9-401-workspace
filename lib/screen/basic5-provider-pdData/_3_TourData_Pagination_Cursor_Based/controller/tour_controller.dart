import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/tour_item.dart';

class TourController2 with ChangeNotifier {
  // ── 기존 상태 변수 (유지) ──────────────────────────────────
  final List<TourItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TourItem>  get items        => _items;
  bool            get isLoading    => _isLoading;
  String?         get errorMessage => _errorMessage;

  // 🔴 [변경됨] 1. 페이지네이션을 위한 새로운 상태 변수들 추가
  bool _isFetchingMore = false; // 스크롤 시 추가 로딩 중인지 여부
  bool _hasMore        = true;  // 서버에 더 가져올 데이터가 남아있는지 여부
  int  _currentPage    = 1;     // 현재 요청할 페이지 번호
  static const int _pageSize = 10; // 한 번에 가져올 데이터 개수 (기존 100개 -> 10개로 쪼갬)

  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore        => _hasMore;


  // 🔴 [변경됨] 2. 기존 fetchTourData()를 첫 화면 진입용(fetchInitial)으로 용도 변경
  Future<void> fetchInitial() async {
    // 중복 호출 방지
    if (_isLoading) return;

    // 상태 초기화 (새로고침 시 처음부터 다시 받기 위함)
    _isLoading    = true;
    _errorMessage = null;
    _currentPage  = 1;
    _hasMore      = true;
    _items.clear();
    notifyListeners();

    // 실제 데이터 요청 (내부 메서드 활용)
    await _fetchPage(_currentPage);

    _isLoading = false;
    notifyListeners();
  }

  // 🔴 [변경됨] 3. 스크롤 끝에 닿았을 때 다음 페이지를 불러오는 메서드 추가
  Future<void> fetchMore() async {
    // 중복 호출 및 불필요한 호출 방지
    if (_isFetchingMore) return; // 이미 추가 로딩 중이면 무시
    if (!_hasMore)       return; // 더 가져올 데이터가 없으면 무시
    if (_isLoading)      return; // 첫 화면 로딩 중이면 무시

    _isFetchingMore = true;
    _currentPage++; // 다음 페이지 번호로 증가
    notifyListeners();

    // 실제 데이터 요청 (내부 메서드 활용)
    await _fetchPage(_currentPage);

    _isFetchingMore = false;
    notifyListeners();
  }

  // 🔴 [변경됨] 4. 실제 API와 통신하는 공통 내부 메서드로 분리 (기존 로직 이동)
  Future<void> _fetchPage(int page) async {
    final queryParams = {
      'serviceKey': '본인키', // 본인 인증키
      'pageNo':    page.toString(),         // 🔴 파라미터가 동적으로 변하도록 수정 ('1' -> page.toString())
      'numOfRows': _pageSize.toString(),    // 🔴 100개 고정에서 페이지 사이즈(10개) 변수로 수정
      'resultType': 'json',
    };

    final uri = Uri.https(
      'apis.data.go.kr',
      '/6260000/AttractionService/getAttractionKr',
      queryParams,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final dynamic tourData = decoded['getAttractionKr'];

        if (tourData is Map<String, dynamic> && tourData['item'] is List) {
          final List<dynamic> itemList = tourData['item'];

          // 🔴 기존 _items.clear() 삭제! (다음 페이지 데이터를 기존 리스트에 '추가'해야 하므로)
          _items.addAll(itemList.map((e) => TourItem.fromJson(e)).toList());

          // 🔴 받아온 개수가 요청한 개수(_pageSize)보다 적으면 다음 페이지는 없다고 판단
          if (itemList.length < _pageSize) {
            _hasMore = false;
          }
        } else {
          // 'item' 배열이 없는 경우도 데이터가 끝난 것으로 처리
          _hasMore = false;
        }
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('데이터 로딩 실패: $e');
    }
  }
}