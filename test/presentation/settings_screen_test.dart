import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/presentation/screens/settings/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets(
      'Renders stock clock backup alarm toggle and mandatory cancellation notice',
      (tester) async {
        bool? changedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: SettingsScreen(
              initialBackupAlarmEnabled: false,
              onBackupAlarmChanged: (val) {
                changedValue = val;
              },
            ),
          ),
        );

        // Verify title & settings item
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Stock Clock Backup Alarm'), findsOneWidget);

        // Verify mandatory disclaimer copy regarding manual dismissal (D-005)
        expect(
          find.textContaining(
            'Android does not permit third-party applications to cancel or edit system alarms',
          ),
          findsOneWidget,
        );

        // Toggle switch
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(changedValue, isTrue);
      },
    );
  });
}
