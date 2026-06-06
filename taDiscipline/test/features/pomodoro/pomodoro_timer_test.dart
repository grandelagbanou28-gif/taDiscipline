import 'package:flutter_test/flutter_test.dart';
import 'package:apex/features/pomodoro/screens/pomodoro_screen.dart';

void main() {
  testWidgets('PomodoroScreen se construit sans planter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PomodoroScreen()),
    );
    expect(find.byType(PomodoroScreen), findsOneWidget);
  });
}
