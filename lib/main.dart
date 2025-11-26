import 'package:apk_catalogo/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
