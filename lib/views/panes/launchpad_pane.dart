import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/handlers/apps_handler.dart';
import 'package:strontianite/models/installed_app_model.dart';
import 'package:universal_image/universal_image.dart';

class LaunchpadPane extends StatefulWidget {
  const LaunchpadPane({super.key});

  @override
  State<LaunchpadPane> createState() => _LaunchpadPaneState();
}

class _LaunchpadPaneState extends State<LaunchpadPane> {
  List<InstalledAppModel> _installedApps = [];
  final _controller = SearchController();
  List<InstalledAppModel> _filteredApps = [];

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          SearchAnchor(
            searchController: _controller,
            builder: (context, controller) {
              return SearchBar(
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (value) {
                  controller.openView();
                  debugPrint('On changed: $value');
                  setState(() {
                    _filteredApps = _installedApps
                        .where(
                          (a) => a.name.trim().toLowerCase().contains(value),
                        )
                        .toList();
                  });
                },
                leading: const Icon(M3EIcons.search_rounded),
                hintText: 'Search installed apps',
              );
            },
            suggestionsBuilder: ((context, controller) async {
              return _installedApps
                  .where(
                    (a) => a.name.trim().toLowerCase().contains(
                      controller.text..trim().toLowerCase(),
                    ),
                  )
                  .map((a) {
                    return ListTile(
                      title: Text(a.name),
                      onTap: () {
                        a.launch();
                        controller.closeView(a.name);
                      },
                    );
                  });
            }),
            viewOnSubmitted: (value) {
              debugPrint('On submitted: $value');
              setState(() {
                _filteredApps = _installedApps
                    .where((a) => a.name.trim().toLowerCase().contains(value))
                    .toList();
              });
              _controller.closeView(value);
            },
            viewOnChanged: (value) {
              debugPrint('On changed: $value');
              setState(() {
                _filteredApps = _installedApps
                    .where((a) => a.name.trim().toLowerCase().contains(value))
                    .toList();
              });
            },
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 128,
                mainAxisExtent: 128,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _filteredApps.length,
              itemBuilder: (context, index) {
                final app = _filteredApps[index];
                if (app.linuxIcon != null) {
                  return _buildAppIcon(
                    app.name,
                    UniversalImage(app.linuxIcon!),
                    app.launch,
                  );
                } else if (app.androidIcon != null) {
                  return _buildAppIcon(
                    app.name,
                    Image.memory(app.androidIcon!),
                    app.launch,
                  );
                } else {
                  return _buildAppIcon(
                    app.name,
                    const Icon(M3EIcons.apps_rounded),
                    app.launch,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon(String name, Widget icon, Function launch) {
    return SizedBox(
      width: 128,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                launch();
              },
              borderRadius: BorderRadius.circular(100),
              child: Ink(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: EdgeInsets.all(8),
                child: icon,
              ),
            ),
          ),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _getInstalledApps() async {
    final apps = await AppsHandler.getInstalledApps();
    setState(() {
      _installedApps = apps;
      _filteredApps = _installedApps;
    });
  }
}
