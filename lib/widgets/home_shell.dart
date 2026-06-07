import 'package:flutter/material.dart';

import '../features/ai/presentation/ai_chat_screen.dart';
import '../features/alarm/presentation/alarm_screen.dart';
import '../features/clock/presentation/clock_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stopwatch/presentation/stopwatch_screen.dart';
import '../features/timer/presentation/timer_screen.dart';

/// Root bottom-navigation shell tying every feature together.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    ClockScreen(),
    AlarmScreen(),
    TimerScreen(),
    StopwatchScreen(),
    AiChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.access_time), label: 'Clock'),
          NavigationDestination(icon: Icon(Icons.alarm), label: 'Alarm'),
          NavigationDestination(icon: Icon(Icons.hourglass_bottom), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Stop'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
