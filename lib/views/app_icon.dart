import 'package:flutter/material.dart';
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
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        onPressed: () => exec(),
        icon: Icon(icon),
      ),
    );
  }
}
