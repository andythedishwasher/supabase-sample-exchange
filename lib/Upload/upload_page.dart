import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/storage.dart';
import '../widgets/network_audio_player.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, required this.client, required this.user});

  final SupabaseClient client;
  final User user;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? _photoURL;
  String? _title;
  String? _artist;
  String? _uploadedURL;
  String? _error;

  bool _playerLoaded = false;

  @override
  void initState() {
    if (widget.user.userMetadata!['photoURL'] != null) {
      setState(() => {_photoURL = widget.user.userMetadata!['photoURL']});
    }
    setState(() => {_artist = widget.user.userMetadata!['displayName']});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Upload Sample')),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(_artist ?? 'Unknown Artist',
                  style: const TextStyle(fontSize: 32.0))),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: _photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(_photoURL!),
                    )
                  : const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/favico.png'),
                    )),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 20.0,
                width: 300.0,
                child: TextField(
                  onChanged: (value) => {
                    setState(() => {_title = value})
                  },
                ),
              )),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  child: const Text('Upload Sample'),
                  onPressed: () => {
                        if (_title != null)
                          {
                            uploadSample(widget.client, widget.user, _title!)
                                .then((signedURL) => {
                                      setState(
                                          () => {_uploadedURL = signedURL}),
                                    })
                          }
                        else
                          {
                            setState(
                                () => {_error = 'Give your sample a title'})
                          }
                      })),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: _playerLoaded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Here\'s what you uploaded',
                            style: TextStyle(fontSize: 20.0)),
                        const SizedBox(height: 10.0),
                        NetworkAudioPlayer(
                            artist: _artist!,
                            title: _title!,
                            url: _uploadedURL!),
                      ],
                    )
                  : Text(_error ?? ''))
        ])));
  }
}
