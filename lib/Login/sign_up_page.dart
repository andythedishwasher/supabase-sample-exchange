import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'login_page.dart';
import '../Sample Pool/sample_pool_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.title, required this.client});

  final String title;
  final SupabaseClient client;
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final StreamSubscription<AuthState> _authSubscription;
  User? _user;
  String? _displayName;
  String? _email;
  String? _password;
  String? _confirm;
  String? _SignUpError;

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
              child: Text('Display Name'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                height: 20,
                child: TextField(
                  keyboardType: TextInputType.name,
                  onChanged: (value) => {
                    setState(() => {_displayName = value})
                  },
                ),
              ),
            ),
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
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
              child: Text('Confirm Password'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                height: 20,
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) => {
                    setState(() => {_confirm = value})
                  },
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () async => {
                      if (_displayName != null &&
                          _email!.contains('@') &&
                          _email!.contains('.') &&
                          _password!.length > 8 &&
                          _password == _confirm)
                        {
                          authresponse = await widget.client.auth
                              .signUp(email: _email!, password: _password!),
                          if (authresponse?.user != null)
                            {
                              authresponse!.user!.userMetadata?.addEntries(
                                  [MapEntry('displayName', _displayName)]),
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      SamplePoolPage(
                                          user: _user ?? authresponse!.user!,
                                          client: widget.client),
                                ),
                              )
                            }
                          else
                            {
                              setState(() => {
                                    _SignUpError =
                                        'Check email for confirmation.'
                                  })
                            }
                        }
                      else
                        {
                          setState(
                              () => {_SignUpError = 'Incorrect Field Values'})
                        }
                    },
                child: const Text('Sign Up')),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(_SignUpError ?? ''),
            ),
            ElevatedButton(
              onPressed: () => {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        Login(title: 'Log In', client: widget.client),
                  ),
                )
              },
              child: const Text('Go To Login'),
            )
          ],
        ),
      ),
    );
  }
}
