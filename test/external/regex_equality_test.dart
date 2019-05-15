import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Regexs with same pattern are equatable', () async {
    final r1 = RegExp('^hello(\\d+)\$');
    final r2 = RegExp('^hello(\\d+)\$');
    expect(r1, r2);
  });
}