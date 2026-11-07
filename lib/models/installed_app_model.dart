class InstalledAppModel {
  const InstalledAppModel({
    required this.name,
    required this.icon,
    required this.launch,
  });

  final String name;
  final String? icon;
  final Function launch;
}
