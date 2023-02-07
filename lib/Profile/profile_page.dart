import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.client, required this.user});

  final SupabaseClient client;
  final User user;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _photoURL;
  String? _displayName;
  String? _confirmationError;
  bool _displayNameEdit = false;

  @override
  void initState() {
    if (widget.user.userMetadata != null) {
      if (widget.user.userMetadata!.containsKey('photoURL')) {
        setState(() => {_photoURL = widget.user.userMetadata?['photoURL']});
      }
      if (widget.user.userMetadata!.containsKey('displayName')) {
        setState(
            () => {_displayName = widget.user.userMetadata?['displayName']});
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          backgroundColor: Colors.indigo,
        ),
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1.4,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _photoURL != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(_photoURL!),
                          radius: 70.0)
                      : ElevatedButton(
                          child: const Text('Upload Photo'),
                          onPressed: () async => {
                                if (widget.client.auth.currentSession != null)
                                  {
                                    uploadUserPhoto(widget.client, widget.user)
                                        .then((value) => {
                                              setState(
                                                  () => {_photoURL = value}),
                                              widget.client.auth.updateUser(
                                                  UserAttributes(data: {
                                                'photoURL': value
                                              }))
                                            })
                                  }
                                else
                                  {
                                    setState(() => {
                                          _confirmationError =
                                              'Need to confirm email before editing user data'
                                        })
                                  }
                              })),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: widget.user.userMetadata?['displayName'] != null
                      ? Text(widget.user.userMetadata!['displayName'])
                      : const Text('No Display Name')),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _displayNameEdit
                      ? ElevatedButton(
                          child: const Text('Change Display Name'),
                          onPressed: () => {
                            setState(() => {_displayNameEdit = true})
                          },
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 20.0,
                                  width: 300.0,
                                  child: TextField(
                                    autocorrect: false,
                                    onChanged: (value) => {
                                      setState(() => {_displayName = value})
                                    },
                                  )),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  child: const Text('Save Display Name'),
                                  onPressed: () async => {
                                    if (widget.client.auth.currentSession !=
                                        null)
                                      {
                                        await widget.client.auth.updateUser(
                                            UserAttributes(data: {
                                          'displayName': _displayName
                                        })),
                                        setState(
                                            () => {_displayNameEdit = false})
                                      }
                                    else
                                      {
                                        setState(() => {
                                              _confirmationError =
                                                  'Need to confirm email before editing user data'
                                            })
                                      }
                                  },
                                )),
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: _confirmationError != null
                                    ? Text(_confirmationError!)
                                    : const Text(''))
                          ],
                        ))
            ]),
          ),
        ));
  }
}
