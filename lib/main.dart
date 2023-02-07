import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links_desktop/uni_links_desktop.dart';
import 'dart:io';
//Routes
import 'Login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    registerProtocol('lsdsamples');
  }

  await Supabase.initialize(
    url: 'https://fhibjauqwfumckxpcsia.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoaWJqYXVxd2Z1bWNreHBjc2lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzUzNDQ1OTUsImV4cCI6MTk5MDkyMDU5NX0.pM0p23du8G45YVdUZuBxIgKxsDiXrBFRyZV8bFRVwnc',
  );

  runApp(const SampleExchange());
}

final supabase = Supabase.instance.client;

class SampleExchange extends StatelessWidget {
  const SampleExchange({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Login(title: 'Login', client: supabase),
    );
  }
}
