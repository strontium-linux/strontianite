import 'dart:io';

import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps_plugin/installed_apps_plugin.dart';
import 'package:strontianite/models/installed_app_model.dart';

class AppsHandler {
  static final _installedAppsPlugin = InstalledAppsPlugin();

  static Future<List<InstalledAppModel>> getInstalledApps() async {
    final List<InstalledAppModel> installedApps = [];

    if (Platform.isLinux) {
      final apps = await _installedAppsPlugin.getInstalledApps();
      for (final app in apps) {
        installedApps.add(
          InstalledAppModel(
            name: app.name,
            linuxIcon: app.iconPath,
            androidIcon: null,
            launch: app.launch,
          ),
        );
      }
    } else if (Platform.isAndroid) {
      final apps = await InstalledApps.getInstalledApps(withIcon: true);
      for (final app in apps) {
        installedApps.add(
          InstalledAppModel(
            name: app.name,
            linuxIcon: null,
            androidIcon: app.icon,
            launch: () => InstalledApps.startApp(app.packageName),
          ),
        );
      }
    }

    return installedApps;
  }
}
