import 'package:material_ui/material_ui.dart';
import 'package:strontianite/views/panel.dart';
import 'package:strontianite/views/panes/alarms_pane.dart';
import 'package:strontianite/views/panes/clock_pane.dart';
import 'package:strontianite/views/panes/media_pane.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  final List<Widget> _panels = [ClockPane(), MediaPane(), AlarmsPane()];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
