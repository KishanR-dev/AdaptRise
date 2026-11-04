class SleepSessionData {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final List<SleepStageData> stages;

  const SleepSessionData({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.stages,
  });
}

class SleepStageData {
  final int
  stageType; // 1: Awake, 2: Sleeping, 3: Out-of-bed, 4: Light, 5: Deep, 6: REM
  final DateTime startTime;
  final DateTime endTime;

  const SleepStageData({
    required this.stageType,
    required this.startTime,
    required this.endTime,
  });
}
