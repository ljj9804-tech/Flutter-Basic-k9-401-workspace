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

mixin IdolDanceMixin on Idol{
  void dance(){
    print('${this.name}이 춤을 춥니다!.');
  }
}

// 믹스인을 적용할 때는 with 키워드 사용
class BoyGroup extends Idol with IdolSingMixin,IdolDanceMixin {
  BoyGroup(
      super.name,
      super.membersCount,
      );

  void sayMale() {
    print('저는 남자 아이돌입니다.');
  }
}

class GirlGroup extends Idol with IdolSingMixin,IdolDanceMixin{
  final String name;
  final int membersCount;

  GirlGroup(
      this.name,
      this.membersCount,
      ) : super(   // super는 부모 클래스를 지칭합니다.
  name,
  membersCount,
  );

  void sayName() {
    print('저는 여자 아이돌 ${this.name}입니다.');
  }

  void sayMembersCount() {
    print('${this.name} 멤버는 ${this.membersCount}명입니다.');
  }
}

void main(){
  BoyGroup bts = BoyGroup('BTS', 7);

  // 믹스인에 정의된 dance() 함수와 sing() 함수 사용 가능
  bts.sing();
  bts.dance();

  GirlGroup redVelvet = GirlGroup('레드벨벳', 5);

  redVelvet.sayName();
  redVelvet.sayMembersCount();
  bts.sing();
  bts.dance();
}