import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/domain/models/shift_decision_note.dart';
import 'package:adaptrise/presentation/screens/timeline/timeline_screen.dart';

void main() {
  group('TimelineScreen Widget Tests', () {
    testWidgets(
      'Renders timeline cards with target, actual, badge and explanation',
      (tester) async {
        final sampleItems = [
          TimelineItemData(
            targetDate: DateTime(2026, 11, 4),
            scheduledTarget: DateTime(2026, 11, 4, 7, 0),
            actualWake: DateTime(2026, 11, 4, 7, 45),
            decisionNote: const ShiftDecisionNote(
              rule: ShiftDecisionRule.caseAOverslept,
              shiftMinutes: 30,
              deltaOversleepMinutes: 45,
              note: 'Overslept by 45 min. Eased target wake time by +30 min to prevent circadian disruption.',
              tags: {'rule': 'CASE_A', 'overslept': '+45m', 'shift': '+30m'},
            ),
          ),
          TimelineItemData(
            targetDate: DateTime(2026, 11, 5),
            scheduledTarget: DateTime(2026, 11, 5, 7, 0),
            actualWake: DateTime(2026, 11, 5, 6, 50),
            decisionNote: const ShiftDecisionNote(
              rule: ShiftDecisionRule.caseB1OnTimeRamp,
              shiftMinutes: -15,
              deltaOversleepMinutes: -10,
              note: 'Target met. Advancing wake time by -15 min toward goal of 06:30.',
              tags: {'rule': 'CASE_B1_RAMP', 'shift': '-15m', 'goal': '06:30'},
            ),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(home: TimelineScreen(items: sampleItems)),
        );

        // Verify Screen title
        expect(find.text('Sleep-Shift Timeline'), findsOneWidget);

        // Verify date labels
        expect(find.text('Nov 4'), findsOneWidget);
        expect(find.text('Nov 5'), findsOneWidget);

        // Verify Shift Badges
        expect(find.text('+30m'), findsOneWidget);
        expect(find.text('-15m'), findsOneWidget);

        // Verify Clock Times
        expect(find.text('07:00'), findsNWidgets(2));
        expect(find.text('07:45'), findsOneWidget);
        expect(find.text('06:50'), findsOneWidget);

        // Verify Explanation Notes
        expect(find.textContaining('Overslept by 45 min'), findsOneWidget);
        expect(find.textContaining('Target met'), findsOneWidget);
      },
    );
  });
}
