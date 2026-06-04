import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TutorApp());
    expect(find.text('Tutores Acadêmicos'), findsOneWidget);
  });
}
