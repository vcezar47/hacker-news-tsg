import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../models/story.dart';

/// Swipe a card right to save / unsave it, left to open its comments. The card springs
/// back either way; only the action runs.
class SwipeActions extends StatelessWidget {
  const SwipeActions({
    super.key,
    required this.story,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenComments,
    required this.child,
    this.featured = false,
  });

  final Story story;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenComments;
  final bool
  featured; // the first card has a larger corner radius and top margin
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Same margin and corner radius as StoryCard, so the colour behind it lines up.
    Widget background(
      Alignment align,
      Color fill,
      Color fg,
      IconData icon,
      String label,
    ) {
      return Container(
        margin: EdgeInsets.fromLTRB(16, featured ? 8 : 6, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: align,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(featured ? 22 : 18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Dismissible(
      key: ValueKey('swipe-${story.id}'),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.3,
        DismissDirection.endToStart: 0.3,
      },
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        if (direction == DismissDirection.startToEnd) {
          onToggleFavorite();
        } else {
          onOpenComments();
        }
        return false; // never remove the card from the list
      },
      background: background(
        Alignment.centerLeft,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        isFavorite ? Icons.star_border : Icons.star,
        isFavorite ? 'Unsave' : 'Save',
      ),
      secondaryBackground: background(
        Alignment.centerRight,
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.chat_bubble_outline,
        'Comments',
      ),
      child: child,
    );
  }
}
