mixin class MixinExample {}

class Child1 extends MixinExample {}  // ✅ extend 가능
class Child2 with MixinExample {}     // ✅ mixin으로 사용 가능