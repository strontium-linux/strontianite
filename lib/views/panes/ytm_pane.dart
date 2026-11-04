import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:strontianite/models/play_model.dart';
import 'package:strontianite/utils/ytm_utils.dart';
import 'package:strontianite/views/now_playing.dart';
import 'package:strontianite/views/ytm_settings.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtmPane extends StatefulWidget {
  const YtmPane({super.key});

  @override
  State<YtmPane> createState() => _YtmPaneState();
}

class _YtmPaneState extends State<YtmPane> with AutomaticKeepAliveClientMixin {
  List<Video> _content = List.empty();
  final _controller = SearchController();
  final ValueNotifier<PlayModel> _playTrigger = ValueNotifier(
    PlayModel(
      title: YtmUtils.getTitle(),
      artist: YtmUtils.getArtist(),
      thumbnail: YtmUtils.getThumbnail(),
    ),
  );
  late NowPlaying _nowPlaying;
  final ValueNotifier<bool> _loadTrigger = ValueNotifier(false);
  bool _isResultsLoading = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nowPlaying = NowPlaying(
      playTrigger: _playTrigger,
      loadTrigger: _loadTrigger,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                hintText: 'Search songs on YouTube Music',
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
            child: _content.isEmpty && !_isResultsLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      const Icon(M3EIcons.search_rounded),
                      const Text('Start searching for your favourite songs'),
                    ],
                  )
                : Skeletonizer(
                    enabled: _isResultsLoading,
                    effect: ShimmerEffect(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _isResultsLoading ? 4 : _content.length,
                      itemBuilder: (context, i) {
                        final c = _isResultsLoading ? null : _content[i];
                        return ListTile(
                          leading: M3EContainer.circle(
                            width: 40,
                            height: 40,
                            child: ClipOval(
                              child: SizedBox.square(
                                dimension: 40,
                                child: c != null
                                    ? Image.network(
                                        c.thumbnails.mediumResUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(M3EIcons.music_note_rounded),
                              ),
                            ),
                          ),
                          title: Text(c?.title ?? 'Cool Song Title'),
                          subtitle: Text(
                            c?.author ?? 'Author 1, Author 2 & Author 3',
                          ),
                          onTap: () {
                            if (c == null) return;
                            YtmUtils.play(
                              c.id.toString(),
                              _nowPlaying.playTrigger,
                              (isLoading) {
                                if (mounted) {
                                  setState(() {
                                    _loadTrigger.value = isLoading;
                                  });
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
          _nowPlaying,
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _search(String query) async {
    setState(() {
      _isResultsLoading = true;
    });
    final results = await YtmUtils.search(query);
    setState(() {
      _content = results;
      _isResultsLoading = false;
    });
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}
