import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lists and sets with the same contents are equatable in tests', () async {
    List<String> list = ['a', 'b', 'c'];
    Set<String> set = Set.from(['a', 'b', 'c']);
    expect(list, set);
  });
}