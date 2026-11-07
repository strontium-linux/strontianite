import 'package:material_ui/material_ui.dart';
import 'package:strontianite/handlers/alarms_handler.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/providers/alarms_provider.dart';
import 'package:strontianite/views/alarm_ringing.dart';
import 'package:strontianite/views/panel.dart';
import 'package:strontianite/views/panes/alarms_pane.dart';
import 'package:strontianite/views/panes/clock_pane.dart';
import 'package:strontianite/views/panes/launchpad_pane.dart';
import 'package:strontianite/views/panes/media_pane.dart';
import 'package:strontianite/views/panes/ytm_pane.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  final List<Widget> _panels = [
    ClockPane(),
    MediaPane(),
    AlarmsPane(),
    YtmPane(),
    LaunchpadPane(),
  ];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    AlarmsHandler.ringEvents.listen((id) {
      final alarm = container.read(alarmsProvider.notifier).getAlarm(id);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlarmRinging(alarm: alarm)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Panel(
          switchPane: (i) {
            setState(() {
              _pageController.jumpToPage(i);
            });
          },
        ),
        Expanded(
          child: PageView(controller: _pageController, children: _panels),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
