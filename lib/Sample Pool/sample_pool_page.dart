import "package:flutter/material.dart";
import 'package:lsd_sample_exchange/Upload/upload_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Login/login_page.dart';
import '../Profile/profile_page.dart';
import '../widgets/network_audio_player.dart';
import '../supabase/storage.dart';

class SamplePoolPage extends StatefulWidget {
  const SamplePoolPage({Key? key, required this.user, required this.client});
  final User user;
  final SupabaseClient client;
  @override
  _SamplePoolPageState createState() => _SamplePoolPageState();
}

class _SamplePoolPageState extends State<SamplePoolPage> {
  List<Sample>? _samples;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Pool'),
        actionsIconTheme: const IconThemeData(color: Colors.green),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(client: widget.client, user: widget.user)),
              );
            },
          ),
        ],
        backgroundColor: Colors.indigo,
      ),
      body: Center(
          child: Column(
        children: [
          _samples != null
              ? SizedBox(
                  height: 400.0,
                  child: ListView.builder(
                      itemCount: _samples?.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            const SizedBox(height: 10.0),
                            NetworkAudioPlayer(
                                artist:
                                    _samples![index].artist ?? 'unkown artist',
                                title:
                                    _samples![index].title ?? 'unknown title',
                                url: _samples![index].url!),
                            const SizedBox(height: 10.0),
                            ElevatedButton(
                                child: const Text('Claim Sample'),
                                onPressed: () async => {
                                      await claimSample(
                                          widget.client,
                                          _samples![index].artist ??
                                              'unknown artist',
                                          _samples![index].title ??
                                              'unknown title'),
                                      samplePool(widget.client)
                                          .then((samples) => {
                                                setState(
                                                    () => {_samples = samples})
                                              })
                                    })
                          ],
                        );
                      }),
                )
              : ElevatedButton(
                  child: const Text('Get Samples'),
                  onPressed: () => {
                        samplePool(widget.client).then((samples) => {
                              setState(() => {_samples = samples})
                            })
                      }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.user.email!),
          ),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                child: const Text('Upload Sample'),
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => UploadPage(
                              client: widget.client, user: widget.user)))
                },
              )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              child: const Text('Sign Out'),
              onPressed: () async => {
                await widget.client.auth.signOut(),
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        Login(title: 'Login', client: widget.client),
                  ),
                )
              },
            ),
          )
        ],
      )),
    );
  }
}
