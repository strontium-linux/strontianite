import 'dart:async';

import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:marquee/marquee.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/models/play_model.dart';
import 'package:strontianite/utils/ytm_utils.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key, required this.playTrigger});

  final ValueNotifier<PlayModel> playTrigger;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  double _sliderValue = 0;
  bool _isPlaying = false;
  late Timer _updateTimer;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(Duration(milliseconds: 300), (_) {
      if (!mounted) return;

      setState(() {
        if (!_isSeeking) {
          _sliderValue =
              YtmUtils.getPosition().inMilliseconds /
              YtmUtils.getDuration().inMilliseconds;
        }
        _isPlaying = YtmUtils.isPlaying();
      });
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
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              M3EContainer.circle(
                width: 32,
                height: 32,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: value.thumbnail != null
                    ? ClipOval(
                        child: Image.network(
                          value.thumbnail!,
                          fit: BoxFit.cover,
                          width: 32,
                          height: 32,
                        ),
                      )
                    : const Icon(M3EIcons.music_note_rounded),
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
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    showValueIndicator: ShowValueIndicator.onDrag,
                  ),
                  child: M3ESlider(
                    value: _sliderValue,
                    label: '${_sliderValue}s',
                    onChanged: (value) {
                      _isSeeking = true;
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                    onChangeEnd: (value) async {
                      await YtmUtils.seekTo(value);
                      _isSeeking = false;
                    },
                  ),
                ),
              ),
              _isPlaying
                  ? M3EIconButton(
                      variant: M3EIconButtonVariant.tonal,
                      icon: const Icon(M3EIcons.pause_rounded),
                      onPressed: () {
                        YtmUtils.setPlaying(false);
                      },
                    )
                  : M3EIconButton(
                      variant: M3EIconButtonVariant.tonal,
                      icon: const Icon(M3EIcons.play_arrow_rounded),
                      onPressed: () {
                        YtmUtils.setPlaying(true);
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
}
