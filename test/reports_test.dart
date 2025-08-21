import 'package:flutter_test/flutter_test.dart';
import 'package:medioambienterd/screens/Reports/report_damage_screen.dart';
import 'package:medioambienterd/screens/Reports/my_reports_screen.dart';
import 'package:medioambienterd/screens/Reports/reports_map_screen.dart';

void main() {
  testWidgets('Report screens can be instantiated', (
    WidgetTester tester,
  ) async {
    // Test that our screens can be created without errors
    expect(() => const ReportDamageScreen(), isNot(throwsA(anything)));
    expect(() => const MyReportsScreen(), isNot(throwsA(anything)));
    expect(() => const ReportsMapScreen(), isNot(throwsA(anything)));
  });
}
