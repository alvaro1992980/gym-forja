import 'package:material_ui/material_ui.dart';

/// Horizontally scrollable row of filter chips. Not lazy: there are only a
/// few chips, and all of them stay reachable (and testable).
class ChipBar extends StatelessWidget {
  const ChipBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: children),
    );
  }
}
