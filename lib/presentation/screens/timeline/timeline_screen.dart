import 'package:flutter/material.dart';
import 'package:adaptrise/domain/models/shift_decision_note.dart';
import 'package:adaptrise/domain/engine/shift_calculator.dart';

class TimelineScreen extends StatelessWidget {
  final List<TimelineItemData> items;

  const TimelineScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090C), // Obsidian void background
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141A),
        title: const Text(
          'Sleep-Shift Timeline',
          style: TextStyle(
            color: Color(0xFFF2F4F8),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return TimelineCard(item: item);
        },
      ),
    );
  }
}

class TimelineItemData {
  final DateTime targetDate;
  final DateTime scheduledTarget;
  final DateTime actualWake;
  final ShiftDecisionNote decisionNote;

  const TimelineItemData({
    required this.targetDate,
    required this.scheduledTarget,
    required this.actualWake,
    required this.decisionNote,
  });
}

class TimelineCard extends StatelessWidget {
  final TimelineItemData item;

  const TimelineCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final badge = ShiftCalculator.formatShiftBadge(
      item.decisionNote.shiftMinutes,
    );
    final isForward = item.decisionNote.shiftMinutes > 0;
    final targetStr = _formatTime(item.scheduledTarget);
    final actualStr = _formatTime(item.actualWake);
    final dateStr = _formatDate(item.targetDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A), // Surface container
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF1C1F26), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  color: Color(0xFF8A91A0),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: isForward
                      ? const Color(0xFFE06C38).withValues(alpha: 0.2)
                      : const Color(0xFF4ECCA3).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isForward
                        ? const Color(0xFFFF9E3B)
                        : const Color(0xFF4ECCA3),
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TimeDisplayColumn(label: 'Target Wake', timeStr: targetStr),
              _TimeDisplayColumn(label: 'Actual Wake', timeStr: actualStr),
            ],
          ),
          const SizedBox(height: 12.0),
          const Divider(color: Color(0xFF1C1F26)),
          const SizedBox(height: 8.0),
          Text(
            item.decisionNote.note,
            style: const TextStyle(
              color: Color(0xFFF2F4F8),
              fontSize: 13.0,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _TimeDisplayColumn extends StatelessWidget {
  final String label;
  final String timeStr;

  const _TimeDisplayColumn({required this.label, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A91A0), fontSize: 12.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          timeStr,
          style: const TextStyle(
            color: Color(0xFFF2F4F8),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
