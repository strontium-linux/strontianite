import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/utils/ytm_utils.dart';
import 'package:strontianite/views/ytm_settings.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtmPane extends StatefulWidget {
  const YtmPane({super.key});

  @override
  State<YtmPane> createState() => _YtmPaneState();
}

class _YtmPaneState extends State<YtmPane> {
  List<Video> _content = List.empty();
  final _controller = SearchController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(M3EIcons.search_rounded),
                trailing: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => YtmSettings()),
                      );
                    },
                    icon: const Icon(M3EIcons.settings_rounded),
                  ),
                ],
              );
            },
            suggestionsBuilder: ((context, controller) async {
              return (await YtmUtils.getSuggestions(controller.text)).map((r) {
                return ListTile(
                  title: Text(r),
                  onTap: () {
                    _search(r);
                    controller.closeView(r);
                  },
                );
              });
            }),
            viewOnSubmitted: (value) {
              debugPrint('On submitted: $value');
              _search(value);
              _controller.closeView(value);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _content.length,
              itemBuilder: (context, i) {
                final c = _content[i];
                return ListTile(
                  title: Text(c.title),
                  subtitle: Text(c.author),
                  onTap: () {
                    YtmUtils.play(c.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _search(String query) async {
    final results = await YtmUtils.search(query);
    setState(() {
      _content = results;
    });
  }
}
