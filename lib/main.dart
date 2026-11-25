import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/favorites_provider.dart';
import 'providers/read_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stories_provider.dart';
import 'screens/home_screen.dart';
import 'services/calendar_service.dart';
import 'services/hn_api.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final api = HnApi();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider(create: (_) => StoriesProvider(api, prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(prefs, api)),
        ChangeNotifierProvider(create: (_) => ReadProvider(prefs)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        Provider(create: (_) => CalendarService()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HN Reader',
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: context.watch<SettingsProvider>().themeMode,
      home: const HomeScreen(),
    );
  }
}
