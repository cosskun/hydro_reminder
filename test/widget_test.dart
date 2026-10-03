import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hydro_reminder/main.dart';
import 'package:hydro_reminder/providers/water_provider.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    final provider = WaterProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const HydroReminderApp(),
      ),
    );
    expect(find.byType(AppRouter), findsOneWidget);
  });
}
