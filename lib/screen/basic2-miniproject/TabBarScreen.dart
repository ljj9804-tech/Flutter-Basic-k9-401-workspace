import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabBarScreen extends StatefulWidget {
  const TabBarScreen({super.key});

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}
class _TabBarScreenState extends State<TabBarScreen>
    with SingleTickerProviderStateMixin {
  // TabController: 탭 전환을 관리하는 컨트롤러
  // vsync에 this를 전달해야 애니메이션이 효율적으로 동작
  late TabController _tabController;

  // 탭 정보 목록
  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.home, 'label': '홈', 'color': Colors.blue},
    {'icon': Icons.search, 'label': '검색', 'color': Colors.green},
    {'icon': Icons.favorite, 'label': '즐겨찾기', 'color': Colors.red},
    {'icon': Icons.person, 'label': '프로필', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    // length: 탭의 총 개수, vsync: 애니메이션 최적화
    _tabController = TabController(length: _tabs.length, vsync: this);

    // 탭 변경 리스너 등록
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // 탭 변경 시 UI 갱신
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('현재: ${_tabs[_tabController.index]['label']}'),
        backgroundColor: _tabs[_tabController.index]['color'] as Color,
        // AppBar 하단에 TabBar 배치
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,   // 인디케이터 색상
          indicatorWeight: 3.0,           // 인디케이터 두께
          labelColor: Colors.white,       // 선택된 탭 텍스트 색상
          unselectedLabelColor: Colors.white70, // 미선택 탭 색상
          isScrollable: false,            // 탭이 화면 너비에 맞게 균등 배치
          tabs: _tabs.map((tab) {
            return Tab(
              icon: Icon(tab['icon'] as IconData),
              text: tab['label'] as String,
            );
          }).toList(),
        ),
      ),
      // TabBarView: 각 탭에 대응하는 화면
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return Container(
            color: (tab['color'] as Color).withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 80,
                    color: tab['color'] as Color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${tab['label']} 화면',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tab['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      // 하단 탭 버튼 (프로그래매틱 이동 예시)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            _tabs.length,
                (index) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _tabController.index == index
                    ? _tabs[index]['color'] as Color
                    : Colors.grey,
              ),
              onPressed: () {
                // 특정 탭으로 애니메이션 이동
                _tabController.animateTo(index);
              },
              child: Text('탭${index + 1}'),
            ),
          ),
        ),
      ),
    );
  }
}
