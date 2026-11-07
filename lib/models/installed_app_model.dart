import 'dart:typed_data';

class InstalledAppModel {
  const InstalledAppModel({
    required this.name,
    required this.linuxIcon,
    required this.androidIcon,
    required this.launch,
  });

  final String name;
  final String? linuxIcon;
  final Uint8List? androidIcon;
  final Function launch;
}
