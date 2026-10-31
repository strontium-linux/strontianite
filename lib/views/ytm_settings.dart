import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/providers/settings_provider.dart';

class YtmSettings extends ConsumerStatefulWidget {
  const YtmSettings({super.key});

  @override
  ConsumerState<YtmSettings> createState() => _YtmSettingsState();
}

class _YtmSettingsState extends ConsumerState<YtmSettings> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(settingsProvider).youtubeCookie;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Music settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            M3ETextField(
              label: 'YouTube cookie',
              controller: _controller,
              onSubmitted: (value) {
                ref.read(settingsProvider.notifier).updateYoutubeCookie(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
