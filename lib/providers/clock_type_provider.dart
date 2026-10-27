import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strontianite/enums/clock_type.dart';
import 'package:strontianite/main.dart';

class _ClockTypeNotifier extends Notifier<ClockType> {
  @override
  ClockType build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final storedType = prefs.getString('clock_type');

    if (storedType != null) {
      return ClockType.values.firstWhere(
        (type) => type.name == storedType,
        orElse: () => ClockType.flex,
      );
    }

    return ClockType.flex;
  }

  Future<void> setClockType(ClockType type) async {
    state = type;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('clock_type', type.name);
  }
}

final clockTypeProvider = NotifierProvider<_ClockTypeNotifier, ClockType>(
  _ClockTypeNotifier.new,
);
