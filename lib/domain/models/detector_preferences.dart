class DetectorPreferences {
  final int wakeWindowMinutes;
  final int quarantineMinutes;
  final double motionVarianceThreshold;
  final double hrSpikeRatioThreshold;
  final int consecutiveEpochsRequired;

  const DetectorPreferences({
    this.wakeWindowMinutes = 30,
    this.quarantineMinutes = 5,
    this.motionVarianceThreshold =
        0.15, // Calibrated against t1_sensor_recording.csv
    this.hrSpikeRatioThreshold = 1.08, // +8% baseline elevation
    this.consecutiveEpochsRequired = 2,
  });

  DetectorPreferences copyWith({
    int? wakeWindowMinutes,
    int? quarantineMinutes,
    double? motionVarianceThreshold,
    double? hrSpikeRatioThreshold,
    int? consecutiveEpochsRequired,
  }) {
    return DetectorPreferences(
      wakeWindowMinutes: wakeWindowMinutes ?? this.wakeWindowMinutes,
      quarantineMinutes: quarantineMinutes ?? this.quarantineMinutes,
      motionVarianceThreshold:
          motionVarianceThreshold ?? this.motionVarianceThreshold,
      hrSpikeRatioThreshold:
          hrSpikeRatioThreshold ?? this.hrSpikeRatioThreshold,
      consecutiveEpochsRequired:
          consecutiveEpochsRequired ?? this.consecutiveEpochsRequired,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wakeWindowMinutes': wakeWindowMinutes,
      'quarantineMinutes': quarantineMinutes,
      'motionVarianceThreshold': motionVarianceThreshold,
      'hrSpikeRatioThreshold': hrSpikeRatioThreshold,
      'consecutiveEpochsRequired': consecutiveEpochsRequired,
    };
  }

  factory DetectorPreferences.fromMap(Map<String, dynamic> map) {
    return DetectorPreferences(
      wakeWindowMinutes: map['wakeWindowMinutes'] as int? ?? 30,
      quarantineMinutes: map['quarantineMinutes'] as int? ?? 5,
      motionVarianceThreshold:
          (map['motionVarianceThreshold'] as num?)?.toDouble() ?? 0.15,
      hrSpikeRatioThreshold:
          (map['hrSpikeRatioThreshold'] as num?)?.toDouble() ?? 1.08,
      consecutiveEpochsRequired: map['consecutiveEpochsRequired'] as int? ?? 2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectorPreferences &&
          runtimeType == other.runtimeType &&
          wakeWindowMinutes == other.wakeWindowMinutes &&
          quarantineMinutes == other.quarantineMinutes &&
          motionVarianceThreshold == other.motionVarianceThreshold &&
          hrSpikeRatioThreshold == other.hrSpikeRatioThreshold &&
          consecutiveEpochsRequired == other.consecutiveEpochsRequired;

  @override
  int get hashCode =>
      wakeWindowMinutes.hashCode ^
      quarantineMinutes.hashCode ^
      motionVarianceThreshold.hashCode ^
      hrSpikeRatioThreshold.hashCode ^
      consecutiveEpochsRequired.hashCode;
}
