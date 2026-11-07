import 'dart:async';

import 'package:faded_scrollable/faded_scrollable.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:marquee/marquee.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:strontianite/models/lyrics_model.dart';
import 'package:strontianite/models/play_model.dart';
import 'package:strontianite/models/synced_lyrics_model.dart';
import 'package:strontianite/utils/ytm_utils.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({
    super.key,
    required this.playTrigger,
    required this.loadTrigger,
  });

  final ValueNotifier<PlayModel> playTrigger;
  final ValueNotifier<bool> loadTrigger;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  late Timer _updateTimer;
  bool _isSeeking = false;
  final ValueNotifier<double> _sliderValue = ValueNotifier(0);
  final ValueNotifier _isPlaying = ValueNotifier(false);
  final ValueNotifier<LyricsModel?> _lyricsModel = ValueNotifier(null);
  final ValueNotifier<int> _currentLyricIndex = ValueNotifier(0);
  final _lyricsScrollController = ItemScrollController();
  BuildContext? _activeContext;
  double _viewportHeight = 0;

  String get _sliderLabel {
    final duration = YtmUtils.getDurationFromPercentage(_sliderValue.value);
    return '${duration.inSeconds}s';
  }

  List<SyncedLyricsModel>? _syncedLyrics;

  @override
  void initState() {
    super.initState();

    _updateTimer = Timer.periodic(Duration(milliseconds: 300), (_) {
      if (!mounted) return;

      final position = YtmUtils.getPosition();
      final duration = YtmUtils.getDuration();

      if (!_isSeeking) {
        _sliderValue.value = position.inMilliseconds / duration.inMilliseconds;
      }

      _isPlaying.value = YtmUtils.isPlaying();

      final lyrics = _syncedLyrics;
      if (lyrics != null && lyrics.isNotEmpty) {
        final index = lyrics.lastIndexWhere((l) => l.position <= position);
        final newIndex = index < 0 ? 0 : index;

        if (newIndex != _currentLyricIndex.value) {
          _currentLyricIndex.value = newIndex;
          _scrollToLine(newIndex);
        }
      }
    });

    widget.loadTrigger.addListener(() async {
      if (widget.loadTrigger.value == false) {
        final model = await YtmUtils.fetchLyrics();
        _lyricsModel.value = model;
        _syncedLyrics = (model != null && model.isSynced)
            ? YtmUtils.parseSyncedLyrics(model)
            : null;
        _currentLyricIndex.value = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.playTrigger,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: widget.loadTrigger,
                    builder: (context, value, child) {
                      return ValueListenableBuilder(
                        valueListenable: _sliderValue,
                        builder: (context, sliderValue, child) {
                          return M3EProgressIndicator.circularWavy(
                            value: value == true ? null : sliderValue,
                            size: 56,
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      children: [
                        M3EContainer.circle(
                          width: 32,
                          height: 32,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: _buildImageCore(value, 32),
                        ),
                        Positioned.fill(
                          child: Material(
                            type: MaterialType.transparency,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _showBottomSheet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 144,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 144,
                      height: 20,
                      child: Marquee(
                        text: value.title,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        scrollAxis: Axis.horizontal,
                        blankSpace: 48,
                      ),
                    ),
                    Text(
                      value.artist,
                      style: TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSlider()),
              ValueListenableBuilder(
                valueListenable: _isPlaying,
                builder: (context, value, child) {
                  return value
                      ? M3EIconButton(
                          variant: M3EIconButtonVariant.tonal,
                          icon: const Icon(M3EIcons.pause_rounded),
                          onPressed: () {
                            YtmUtils.setPlaying(false);
                            _isPlaying.value = false;
                          },
                        )
                      : M3EIconButton(
                          variant: M3EIconButtonVariant.tonal,
                          icon: const Icon(M3EIcons.play_arrow_rounded),
                          onPressed: () {
                            YtmUtils.setPlaying(true);
                            _isPlaying.value = true;
                          },
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, innerSetState) => ValueListenableBuilder(
            valueListenable: widget.playTrigger,
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          if (value.thumbnail != null)
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _buildImageCore(value, 300),
                              ),
                            ),
                          Expanded(
                            flex: 6,
                            child: ValueListenableBuilder(
                              valueListenable: _lyricsModel,
                              builder: (context, lyrics, child) {
                                return FadedScrollable(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: (_syncedLyrics == null)
                                        ? Text(
                                            lyrics?.lyrics ?? 'No lyrics data',
                                          )
                                        : LayoutBuilder(
                                            builder: (context, constraints) {
                                              _viewportHeight =
                                                  constraints.maxHeight;
                                              return ValueListenableBuilder(
                                                valueListenable:
                                                    _currentLyricIndex,
                                                builder: (context, lyricIndex, child) {
                                                  return ScrollablePositionedList.separated(
                                                    initialAlignment: 0.5,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                    itemScrollController:
                                                        _lyricsScrollController,
                                                    itemCount:
                                                        _syncedLyrics?.length ??
                                                        1,
                                                    itemBuilder: (context, i) {
                                                      if (i < 0) {
                                                        return Text('');
                                                      }

                                                      final line =
                                                          _syncedLyrics![i];
                                                      final isCurrentLine =
                                                          i == lyricIndex;
                                                      return Builder(
                                                        builder: (context) {
                                                          if (isCurrentLine) {
                                                            _activeContext =
                                                                context;
                                                          }
                                                          return Text(
                                                            line.line,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isCurrentLine
                                                                  ? 32
                                                                  : 24,
                                                              fontWeight:
                                                                  isCurrentLine
                                                                  ? FontWeight
                                                                        .bold
                                                                  : FontWeight
                                                                        .normal,
                                                              fontVariations: [
                                                                FontVariation(
                                                                  'ROND',
                                                                  100,
                                                                ),
                                                              ],
                                                              color:
                                                                  isCurrentLine
                                                                  ? Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary
                                                                  : Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onSurface,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontVariations: [FontVariation('ROND', 100)],
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                value.artist,
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  Row(
                                    children: [
                                      M3EIconButton(
                                        variant: M3EIconButtonVariant.tonal,
                                        icon: const Icon(
                                          M3EIcons.skip_previous_rounded,
                                        ),
                                        onPressed: () async {
                                          await YtmUtils.previous();
                                        },
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: _isPlaying,
                                        builder: (context, value, child) {
                                          return value
                                              ? M3EIconButton(
                                                  variant: M3EIconButtonVariant
                                                      .filled,
                                                  icon: const Icon(
                                                    M3EIcons.pause_rounded,
                                                  ),
                                                  onPressed: () {
                                                    YtmUtils.setPlaying(false);
                                                    _isPlaying.value = false;
                                                  },
                                                )
                                              : M3EIconButton(
                                                  variant: M3EIconButtonVariant
                                                      .filled,
                                                  icon: const Icon(
                                                    M3EIcons.play_arrow_rounded,
                                                  ),
                                                  onPressed: () {
                                                    YtmUtils.setPlaying(true);
                                                    _isPlaying.value = true;
                                                  },
                                                );
                                        },
                                      ),
                                      M3EIconButton(
                                        variant: M3EIconButtonVariant.tonal,
                                        icon: const Icon(
                                          M3EIcons.skip_next_rounded,
                                        ),
                                        onPressed: () async {
                                          await YtmUtils.next();
                                        },
                                      ),
                                    ],
                                  ),
                                  Expanded(child: _buildSlider()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildImageCore(PlayModel value, double size) {
    return value.thumbnail != null
        ? ClipRRect(
            child: Image.network(
              value.thumbnail!,
              fit: BoxFit.cover,
              width: size,
              height: size,
            ),
          )
        : const Icon(M3EIcons.music_note_rounded);
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderThemeData(showValueIndicator: ShowValueIndicator.onDrag),
      child: ValueListenableBuilder(
        valueListenable: _sliderValue,
        builder: (context, value, child) {
          return M3ESlider(
            value: value,
            label: _sliderLabel,
            onChanged: (value) {
              _isSeeking = true;
              _sliderValue.value = value;
            },
            onChangeEnd: (value) async {
              await YtmUtils.seekTo(value);
              _isSeeking = false;
            },
          );
        },
      ),
    );
  }

  void _scrollToLine(int index) {
    if (index < 0 || !_lyricsScrollController.isAttached) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_lyricsScrollController.isAttached) return;

      final context = _activeContext;
      final box = (context != null && context.mounted)
          ? context.findRenderObject() as RenderBox?
          : null;
      final itemHeight = box?.size.height ?? 0;
      final alignment = _viewportHeight > 0
          ? (0.5 - itemHeight / (2 * _viewportHeight)).clamp(0.0, 1.0)
          : 0.5;

      _lyricsScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        alignment: alignment,
      );
    });
  }
}
