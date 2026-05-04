import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/view/game/correspondence_clock_widget.dart';

Widget _buildClock({required Duration duration, required bool active, VoidCallback? onFlag}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: CorrespondenceClock(duration: duration, active: active, onFlag: onFlag),
    ),
  );
}

void main() {
  group('CorrespondenceClock', () {
    testWidgets('displays the initial time correctly', (tester) async {
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 5), active: false));
      await tester.pump();
      expect(find.text('00:05:00', findRichText: true), findsOneWidget);
    });

    testWidgets('does not tick when inactive', (tester) async {
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 5), active: false));
      await tester.pump();
      expect(find.text('00:05:00', findRichText: true), findsOneWidget);

      await tester.pump(const Duration(seconds: 10));
      expect(find.text('00:05:00', findRichText: true), findsOneWidget);
    });

    testWidgets('resets timeLeft to new duration when active changes from true to false', (
      tester,
    ) async {
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 5), active: true));
      await tester.pump();
      expect(find.text('00:05:00', findRichText: true), findsOneWidget);

      // Simulate server sending corrected time when it becomes our turn:
      // active changes (true -> false) and a new duration is provided.
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 3), active: false));
      await tester.pump();

      // timeLeft must be reset to the new server duration, not the locally ticked value.
      expect(find.text('00:03:00', findRichText: true), findsOneWidget);
    });

    testWidgets('resets timeLeft to new duration when active changes from false to true', (
      tester,
    ) async {
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 3), active: false));
      await tester.pump();
      expect(find.text('00:03:00', findRichText: true), findsOneWidget);

      // Simulate becoming our turn: active changes (false -> true) with updated duration.
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 5), active: true));
      await tester.pump();

      expect(find.text('00:05:00', findRichText: true), findsOneWidget);
    });

    testWidgets('resets timeLeft when duration changes without active changing', (tester) async {
      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 5), active: false));
      await tester.pump();
      expect(find.text('00:05:00', findRichText: true), findsOneWidget);

      await tester.pumpWidget(_buildClock(duration: const Duration(minutes: 7), active: false));
      await tester.pump();

      expect(find.text('00:07:00', findRichText: true), findsOneWidget);
    });
  });
}
