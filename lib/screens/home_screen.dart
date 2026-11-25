import 'package:material_ui/material_ui.dart';

import '../widgets/pill_nav.dart';
import 'favorites_screen.dart';
import 'stories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _pages = [StoriesScreen(), FavoritesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Both pages stay alive (scroll position, search text) and cross-fade with a small drift.
      body: Stack(
        children: [
          for (final (i, page) in _pages.indexed)
            IgnorePointer(
              ignoring: i != _index,
              child: ExcludeSemantics(
                excluding: i != _index,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  offset: Offset(
                    i == _index ? 0 : (i < _index ? -0.04 : 0.04),
                    0,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    opacity: i == _index ? 1 : 0,
                    child: page,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: PillNav(
          index: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
