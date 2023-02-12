import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links_desktop/uni_links_desktop.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//Routes
import 'Login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (Platform.isWindows) {
    registerProtocol('lsdsamples');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
