import 'package:material_ui/material_ui.dart';

/// Favorite toggle: the star pops in with a small bounce when switched on.
class StarButton extends StatelessWidget {
  const StarButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.idleColor,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final Color?
  idleColor; // colour of the empty star; defaults to the theme's muted text

  @override
  Widget build(BuildContext context) {
    final idle = idleColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.elasticOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? Colors.amber : idle,
        ),
      ),
    );
  }
}
