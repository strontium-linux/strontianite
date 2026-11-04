import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/models/alarm.dart';
import 'package:strontianite/providers/alarms_provider.dart';

class AlarmsHandler {
  static final _cron = Cron();
  static final Map<String, int> _androidAlarms = {};
  static final Map<String, ScheduledTask> _linuxAlarms = {};
  static final _alarmPlayer = AudioPlayer();
  static final _controller = StreamController<String>.broadcast();
  static Stream<String> get ringEvents => _controller.stream;
  static final _portName = 'alarms_port';
  static final _alarmPort = ReceivePort();

  static void init() {
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(_alarmPort.sendPort, _portName);

    _alarmPort.listen((message) => _controller.add(message));
  }

  static Future<void> registerAlarm(Alarm alarm) async {
    if (_androidAlarms.containsKey(alarm.id) ||
        _linuxAlarms.containsKey(alarm.id)) {
      await unregisterAlarm(alarm.id);
    }

    if (Platform.isAndroid) {
      final id = await _androidScheduleNextDaily(alarm);
      _androidAlarms[alarm.id] = id;
    } else {
      _linuxAlarms[alarm.id] = _cron.schedule(
        Schedule.parse('${alarm.time.minute} ${alarm.time.hour} * * *'),
        () => _ring(alarm.id),
      );
    }
  }

  static Future<int> _androidScheduleNextDaily(Alarm alarm) async {
    final now = DateTime.now();
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    final intId = _uuidToInt(alarm.id);

    await AndroidAlarmManager.oneShotAt(
      target,
      intId,
      _androidRing,
      params: {'id': alarm.id},
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );

    return intId;
  }

  @pragma('vm:entry-point')
  static Future<void> _androidRing(int id, Map<String, dynamic> params) async {
    final alarm = container
        .read(alarmsProvider.notifier)
        .getAlarm(params['id']);

    await _androidScheduleNextDaily(alarm);
    await _ring(params['id']);
  }

  @pragma('vm:entry-point')
  static Future<void> _ring(String id) async {
    debugPrint('Alarm ringing');
    await _alarmPlayer.setAsset('assets/audio/argon.ogg');
    _alarmPlayer.play();
    IsolateNameServer.lookupPortByName(_portName)?.send(id);
  }

  static int _uuidToInt(String uuid) {
    final bytes = utf8.encode(uuid);
    int hash = 0;
    for (final b in bytes) {
      hash = (hash * 31 + b) & 0xFFFFFFFF;
    }
    return hash;
  }

  static Future<void> unregisterAlarm(String id) async {
    if (Platform.isAndroid) {
      final intId = _uuidToInt(id);
      await AndroidAlarmManager.cancel(intId);
    } else if (Platform.isLinux) {
      await _linuxAlarms.remove(id)?.cancel();
    }
  }

  static Future<void> dismiss() async {
    await _alarmPlayer.stop();
  }
}
