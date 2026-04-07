import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/map_provider.dart';

class MapScreen2 extends StatelessWidget {
  const MapScreen2({super.key});

  static const List<Map<String, String>> _placeTypes = [
    {'key': 'restaurant', 'label': '음식점', 'icon': '🍽️'},
    {'key': 'cafe',       'label': '카페',   'icon': '☕'},
    {'key': 'hospital',   'label': '병원',   'icon': '🏥'},
    {'key': 'school',     'label': '학교',   'icon': '🏫'},
    {'key': 'bank',       'label': '은행',   'icon': '🏦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ 지도 & 위치 추적 (Provider)'),
        actions: [
          // Selector: isTracking 변경 시만 이 버튼 리빌드
          Selector<MapProvider, bool>(
            selector: (_, p) => p.isTracking,
            builder: (context, isTracking, _) {
              return IconButton(
                icon: Icon(
                  isTracking ? Icons.location_searching : Icons.location_disabled,
                  color: isTracking ? Colors.red : null,
                ),
                onPressed: () => context.read<MapProvider>().toggleTracking(),
              );
            },
          ),
        ],
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 장소 유형 선택 칩
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: _placeTypes.length,
                  itemBuilder: (context, index) {
                    final type = _placeTypes[index];
                    final isSelected = provider.selectedType == type['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${type['icon']} ${type['label']}'),
                        selected: isSelected,
                        onSelected: (_) =>
                            context.read<MapProvider>().setPlaceType(type['key']!),
                      ),
                    );
                  },
                ),
              ),

              // 검색 중 인디케이터
              if (provider.isSearching)
                const LinearProgressIndicator(minHeight: 2),

              // Google Maps
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: provider.currentPosition != null
                        ? LatLng(provider.currentPosition!.latitude,
                        provider.currentPosition!.longitude)
                        : const LatLng(35.1795, 129.0756),
                    zoom: 15.0,
                  ),
                  onMapCreated: context.read<MapProvider>().onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: provider.markers,
                  polylines: provider.routePoints.length > 1
                      ? {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: provider.routePoints,
                      color: Colors.blue,
                      width: 4,
                    ),
                  }
                      : {},
                  mapType: MapType.normal,
                ),
              ),

              // 주변 장소 목록 (하단 시트)
              if (provider.nearbyPlaces.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: provider.nearbyPlaces.length,
                    itemBuilder: (context, index) {
                      final place = provider.nearbyPlaces[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              if (place.rating != null)
                                Text('⭐ ${place.rating!.toStringAsFixed(1)}',
                                    style: const TextStyle(fontSize: 11,
                                        color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150.0),
        child: FloatingActionButton(
          onPressed: () => context.read<MapProvider>().searchNearby(),
          tooltip: '주변 검색',
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}