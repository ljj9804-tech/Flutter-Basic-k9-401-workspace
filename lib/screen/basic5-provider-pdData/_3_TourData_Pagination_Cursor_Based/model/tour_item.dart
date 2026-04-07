class TourItem {
  final String? mainTitle;   // 관광지명
  final String? subTitle;    // 부제목
  final String? image;       // 대표 이미지
  final String? addr1;       // 주소
  final String? itemcntnts;  // 관광지 소개 내용

  TourItem({
    this.mainTitle,
    this.subTitle,
    this.image,
    this.addr1,
    this.itemcntnts,
  });

  factory TourItem.fromJson(Map<String, dynamic> json) {
    return TourItem(
      mainTitle:  json['MAIN_TITLE'],
      subTitle:   json['SUBTITLE'],
      image:      json['MAIN_IMG_NORMAL'],
      addr1:      json['ADDR1'],
      itemcntnts: json['ITEMCNTNTS'],
    );
  }
}