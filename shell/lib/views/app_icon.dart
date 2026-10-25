import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:just_tooltip/just_tooltip.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.name,
    required this.icon,
    required this.exec,
  });

  final String name;
  final IconData icon;
  final Function exec;

  @override
  Widget build(BuildContext context) {
    return JustTooltip(
      message: name,
      direction: TooltipDirection.right,
      child: M3EIconButton(
        onPressed: () => exec(),
        icon: Icon(icon),
        decoration: M3EIconButtonDecoration(
          backgroundColor: WidgetStatePropertyAll<Color>(
            Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
