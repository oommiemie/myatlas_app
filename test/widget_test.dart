import 'package:flutter_test/flutter_test.dart';

import 'package:myatlas_app/main.dart';

void main() {
  testWidgets('App boots to Health screen', (tester) async {
    await tester.pumpWidget(const MyAtlasApp());
    await tester.pump();
    expect(find.text('สุขภาพ'), findsWidgets);
  });
}
