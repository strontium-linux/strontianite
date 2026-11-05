import 'dart:async';

import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:marquee/marquee.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/models/play_model.dart';
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

  String get _sliderLabel {
    final duration = YtmUtils.getDurationFromPercentage(_sliderValue.value);
    return '${duration.inSeconds}s';
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(Duration(milliseconds: 300), (_) {
      if (!mounted) return;

      if (!_isSeeking) {
        _sliderValue.value =
            YtmUtils.getPosition().inMilliseconds /
            YtmUtils.getDuration().inMilliseconds;
      }
      _isPlaying.value = YtmUtils.isPlaying();
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildImageCore(value, 200),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16,
                        children: [
                          Column(
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              _buildSlider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16,
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
                                              variant:
                                                  M3EIconButtonVariant.filled,
                                              icon: const Icon(
                                                M3EIcons.pause_rounded,
                                              ),
                                              onPressed: () {
                                                YtmUtils.setPlaying(false);
                                                _isPlaying.value = false;
                                              },
                                            )
                                          : M3EIconButton(
                                              variant:
                                                  M3EIconButtonVariant.filled,
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
                            ],
                          ),
                        ],
                      ),
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
}
