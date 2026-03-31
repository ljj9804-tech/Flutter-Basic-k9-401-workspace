import 'dart:io';

void main() {
  Map<String, int> students = {};

  while (true) {
    print("\n📌 학생 관리 시스템 (CRUD)");
    print("1. 추가(Create)");
    print("2. 조회(Read)");
    print("3. 수정(Update)");
    print("4. 삭제(Delete)");
    print("5. 검색(Search)");
    print("6. 정렬(Sort)");
    print("7. 종료(Exit)");
    stdout.write("원하는 작업을 선택하세요: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write("학생 이름 입력: ");
        String? name = stdin.readLineSync();
        stdout.write("점수 입력: ");
        int? score = int.tryParse(stdin.readLineSync() ?? '');
        if (name != null && score != null) {
          students[name] = score;
          print("$name 학생이 추가되었습니다.");
        }
        break;

      case '2':
        students.forEach((name, score) => print("이름: $name, 점수: $score"));
        break;

      case '3':
        stdout.write("수정할 학생 이름: ");
        String? name = stdin.readLineSync();
        if (students.containsKey(name)) {
          stdout.write("새 점수: ");
          int? newScore = int.tryParse(stdin.readLineSync() ?? '');
          if (newScore != null) students[name!] = newScore;
        }
        break;

      case '4':
        stdout.write("삭제할 학생 이름: ");
        String? name = stdin.readLineSync();
        students.remove(name);
        break;

      case '5':
        stdout.write("검색할 학생 이름: ");
        String? name = stdin.readLineSync();
        print(students.containsKey(name) ? "${students[name]}점" : "없음");
        break;

      case '6':
        var sorted = students.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        for (var e in sorted) print("${e.key}: ${e.value}");
        break;

      case '7':
        return;
    }
  }
}