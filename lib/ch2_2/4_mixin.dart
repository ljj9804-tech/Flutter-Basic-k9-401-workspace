class Idol {
  final String name;
  final int membersCount;

  Idol(this.name, this.membersCount);

  void sayName() {
    print('저는 ${this.name}입니다.');
  }

  void sayMembersCount() {
    print('${this.name} 멤버는 ${this.membersCount}명입니다.');
  }
}

//on 키워드를 적용해서, 특정 클래스 또는
// 그 자식 클래스에만 적용 가능하게 설정.
mixin IdolSingMixin on Idol{
  void sing(){
    print('${this.name}이 노래를 부릅니다.');
  }
}

// 믹스인을 적용할 때는 with 키워드 사용
class BoyGroup extends Idol with IdolSingMixin{
  BoyGroup(
      super.name,
      super.membersCount,
      );

  void sayMale() {
    print('저는 남자 아이돌입니다.');
  }
}

void main(){
  BoyGroup bts = BoyGroup('BTS', 7);

  // 믹스인에 정의된 dance() 함수와 sing() 함수 사용 가능
  bts.sing();
}