import 'package:material_ui/material_ui.dart';

/// Floating bottom bar with a highlight that slides between the two tabs.
class PillNav extends StatelessWidget {
  const PillNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.newspaper, 'Stories'),
    (Icons.star, 'Favorites'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: index == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            // fill the whole bar so each label is centred both ways inside its half
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => onChanged(i),
                        child: Center(
                          child: TweenAnimationBuilder<Color?>(
                            duration: const Duration(milliseconds: 250),
                            tween: ColorTween(
                              end: i == index
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                            builder: (_, color, _) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_items[i].$1, size: 20, color: color),
                                const SizedBox(width: 8),
                                Text(
                                  _items[i].$2,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
