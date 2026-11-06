class SyncedLyricsModel {
  const SyncedLyricsModel({required this.line, required this.timestamp});

  final String line;
  final String timestamp;

  Duration get position {
    final parts = timestamp.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = double.parse(parts[1]);
    return Duration(minutes: minutes, milliseconds: (seconds * 1000).round());
  }
}
