import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool initialBackupAlarmEnabled;
  final ValueChanged<bool> onBackupAlarmChanged;

  const SettingsScreen({
    super.key,
    required this.initialBackupAlarmEnabled,
    required this.onBackupAlarmChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _backupAlarmEnabled;

  @override
  void initState() {
    super.initState();
    _backupAlarmEnabled = widget.initialBackupAlarmEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090C), // Obsidian void background
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141A),
        title: const Text(
          'Settings',
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
          Container(
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
                    const Expanded(
                      child: Text(
                        'Stock Clock Backup Alarm',
                        style: TextStyle(
                          color: Color(0xFFF2F4F8),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: _backupAlarmEnabled,
                      activeThumbColor: const Color(
                        0xFFFF9E3B,
                      ), // Amber dawn accent
                      onChanged: (val) {
                        setState(() {
                          _backupAlarmEnabled = val;
                        });
                        widget.onBackupAlarmChanged(val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Sets a fallback deadline alarm via the system Clock app (ACTION_SET_ALARM).',
                  style: TextStyle(color: Color(0xFF8A91A0), fontSize: 13.0),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1F26),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: const Color(0xFFFF9E3B).withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFFF9E3B),
                        size: 18.0,
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Important: Android does not permit third-party applications to cancel or edit system alarms. If you wake up early, you must turn off the stock clock alarm manually in your Samsung Clock app.',
                          style: TextStyle(
                            color: Color(0xFFF2F4F8),
                            fontSize: 12.0,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
