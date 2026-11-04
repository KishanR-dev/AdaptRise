import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/domain/models/detector_preferences.dart';

void main() {
  group('DetectorPreferences Tests', () {
    test('Default constructor uses verified calibration parameters', () {
      const prefs = DetectorPreferences();
      expect(prefs.wakeWindowMinutes, equals(30));
      expect(prefs.quarantineMinutes, equals(5));
      expect(prefs.motionVarianceThreshold, equals(0.15));
      expect(prefs.hrSpikeRatioThreshold, equals(1.08));
      expect(prefs.consecutiveEpochsRequired, equals(2));
    });

    test('copyWith updates individual parameters correctly', () {
      const prefs = DetectorPreferences();
      final updated = prefs.copyWith(
        motionVarianceThreshold: 0.20,
        quarantineMinutes: 3,
      );

      expect(updated.motionVarianceThreshold, equals(0.20));
      expect(updated.quarantineMinutes, equals(3));
      expect(updated.wakeWindowMinutes, equals(30)); // Unchanged
    });

    test('toMap and fromMap serialize and deserialize correctly', () {
      const prefs = DetectorPreferences(
        wakeWindowMinutes: 25,
        quarantineMinutes: 4,
        motionVarianceThreshold: 0.12,
        hrSpikeRatioThreshold: 1.10,
        consecutiveEpochsRequired: 3,
      );

      final map = prefs.toMap();
      final restored = DetectorPreferences.fromMap(map);

      expect(restored, equals(prefs));
    });
  });
}
