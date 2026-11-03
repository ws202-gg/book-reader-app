import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/reader_store.dart';
import 'screens/auth_screens.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await ReaderStore.open();
  runApp(NovelReaderApp(store: store));
}

class NovelReaderApp extends StatelessWidget {
  const NovelReaderApp({super.key, required this.store});

  final ReaderStore store;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      title: 'Novel Reader',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: store.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: WelcomeScreen(
        store: store,
        onAuthenticated: (context) => openReaderApp(context, store),
      ),
    ),
  );
}

void openReaderApp(BuildContext context, ReaderStore store) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => MainShell(store: store)),
    (_) => false,
  );
}
