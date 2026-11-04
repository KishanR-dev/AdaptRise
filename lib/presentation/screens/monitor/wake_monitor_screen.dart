import 'package:flutter/material.dart';

enum DiagnosticStatus { granted, warning, denied }

enum WakeMonitorState { active, armed, disabled }

class DiagnosticItem {
  final String title;
  final String description;
  final DiagnosticStatus status;
  final String actionLabel;
  final VoidCallback onAction;

  const DiagnosticItem({
    required this.title,
    required this.description,
    required this.status,
    required this.actionLabel,
    required this.onAction,
  });
}

class WakeMonitorScreen extends StatelessWidget {
  final List<DiagnosticItem> diagnostics;
  final WakeMonitorState monitorState;
  final String currentWakeTargetStr;

  const WakeMonitorScreen({
    super.key,
    required this.diagnostics,
    this.monitorState = WakeMonitorState.armed,
    this.currentWakeTargetStr = '07:00',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090C), // Obsidian void background
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141A),
        title: const Text(
          'Wake Monitor & Diagnostics',
          style: TextStyle(
            color: Color(0xFFF2F4F8),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _WakeWindowStatusCard(
            monitorState: monitorState,
            wakeTargetStr: currentWakeTargetStr,
          ),
          const SizedBox(height: 20.0),
          const Text(
            'SYSTEM & SENSOR DIAGNOSTICS',
            style: TextStyle(
              color: Color(0xFF8A91A0),
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12.0),
          ...diagnostics.map((item) => _DiagnosticCard(item: item)),
        ],
      ),
    );
  }
}

class _WakeWindowStatusCard extends StatelessWidget {
  final WakeMonitorState monitorState;
  final String wakeTargetStr;

  const _WakeWindowStatusCard({
    required this.monitorState,
    required this.wakeTargetStr,
  });

  @override
  Widget build(BuildContext context) {
    String headerText;
    Color statusColor;
    String descriptionText;

    switch (monitorState) {
      case WakeMonitorState.active:
        headerText = 'WAKE WINDOW ACTIVE';
        statusColor = const Color(0xFFFF9E3B);
        descriptionText =
            'Streaming 5-second wrist telemetry from Galaxy Watch 4...';
        break;
      case WakeMonitorState.armed:
        headerText = 'ALARM ARMED';
        statusColor = const Color(0xFF4ECCA3);
        descriptionText = 'Guaranteed hard deadline and wake window scheduled.';
        break;
      case WakeMonitorState.disabled:
        headerText = 'ALARM DISABLED';
        statusColor = const Color(0xFF8A91A0);
        descriptionText = 'No alarm currently scheduled. Tap to configure.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: monitorState == WakeMonitorState.active
              ? const Color(0xFFFF9E3B)
              : const Color(0xFF1C1F26),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            wakeTargetStr,
            style: const TextStyle(
              color: Color(0xFFF2F4F8),
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            descriptionText,
            style: const TextStyle(color: Color(0xFF8A91A0), fontSize: 13.0),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  final DiagnosticItem item;

  const _DiagnosticCard({required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (item.status) {
      case DiagnosticStatus.granted:
        statusColor = const Color(0xFF4ECCA3);
        statusText = 'READY';
        break;
      case DiagnosticStatus.warning:
        statusColor = const Color(0xFFFF9E3B);
        statusText = 'ACTION NEEDED';
        break;
      case DiagnosticStatus.denied:
        statusColor = const Color(0xFFFF5376);
        statusText = 'REQUIRED';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF1C1F26), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFFF2F4F8),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            item.description,
            style: const TextStyle(
              color: Color(0xFF8A91A0),
              fontSize: 13.0,
              height: 1.3,
            ),
          ),
          if (item.status != DiagnosticStatus.granted) ...[
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: item.onAction,
                style: TextButton.styleFrom(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  foregroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  item.actionLabel,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
