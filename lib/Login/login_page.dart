import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'sign_up_page.dart';
import '../Sample Pool/sample_pool_page.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title, required this.client});

  final String title;
  final SupabaseClient client;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final StreamSubscription<AuthState> _authSubscription;
  User? _user;
  String? _email;
  String? _password;
  String? _loginError;

  @override
  void initState() {
    _authSubscription = widget.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      print('session: $session');
      print('change event: $event');
      setState(() {
        _user = session?.user;
      });
      if (data.session?.user != null) {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                SamplePoolPage(user: data.session!.user, client: widget.client),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  AuthResponse? authresponse;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
              child: Text('Email'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                height: 20,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => {
                    setState(() => {_email = value})
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
              child: Text('Password'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                height: 20,
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) => {
                    setState(() => {_password = value})
                  },
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () async => {
                      if (_email!.contains('@') && _email!.contains('.'))
                        {
                          authresponse = await widget.client.auth
                              .signInWithPassword(
                                  email: _email!, password: _password!),
                          if (authresponse?.session != null)
                            {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      SamplePoolPage(
                                          user: _user!, client: widget.client),
                                ),
                              )
                            }
                        }
                      else
                        {
                          setState(
                              () => {_loginError = 'Incorrect Field Values'})
                        }
                    },
                child: const Text('Log In')),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(_loginError ?? ''),
            ),
            ElevatedButton(
              onPressed: () => {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SignUp(title: 'Sign Up', client: widget.client),
                  ),
                )
              },
              child: const Text('Go To Sign Up'),
            )
          ],
        ),
      ),
    );
  }
}
