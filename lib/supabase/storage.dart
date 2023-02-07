import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class Sample {
  String? artist;
  String? title;
  String? url;
  Sample(String this.artist, String this.title, String this.url);
}

Future<String> uploadUserPhoto(SupabaseClient client, User user) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null) {
    String extension = result.files.single.extension!;
    File photoFile = File(result.files.single.path!);
    try {
      await client.storage.from('lsd-media').upload(
            'profile-photos/${user.id}/profile.$extension',
            photoFile,
            fileOptions: const FileOptions(
                cacheControl: '3600', upsert: false, contentType: 'image/png'),
          );
    } on StorageException {
      final String signedUrl = await client.storage
          .from('lsd-media')
          .createSignedUrl('profile-photos/${user.id}/profile.$extension',
              1000 * 1000 * 1000);
      return signedUrl;
    }

    final String signedUrl = await client.storage
        .from('lsd-media')
        .createSignedUrl(
            'profile-photos/${user.id}/profile.$extension', 1000 * 1000 * 1000);
    return signedUrl;
  }
  return 'error';
}

Future<String> uploadSample(
    SupabaseClient client, User user, String title) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result != null) {
    File sampleFile = File(result.files.single.path!);
    String ext = result.files.single.extension!;
    String artist = user.userMetadata?['displayName'] ?? 'unkown';
    try {
      final String path = await client.storage.from('lsd-media').upload(
          'sample-pool/$artist/$title.$ext', sampleFile,
          fileOptions: const FileOptions(contentType: 'audio/mpeg'));
      final FileObject file = await client.storage
          .from('lsd-media')
          .list(path: path)
          .then((value) => value[0]);
    } catch (e) {
      return 'Upload Error: ${e.toString()}';
    }

    String signedUrl = await client.storage
        .from('lsd-media')
        .createSignedUrl('sample-pool/$artist/$title.$ext', 1000 * 1000 * 1000);
    return signedUrl;
  }
  return 'Selection Canceled';
}

Future<List<Sample>> samplePool(SupabaseClient client) async {
  final StorageFileApi bucket = client.storage.from('lsd-media');
  List<FileObject> artistFolders = await bucket.list(path: 'sample-pool');
  List<Sample> samples = [];
  for (FileObject folder in artistFolders) {
    if (folder.name != '.emptyFolderPlaceholder') {
      List<FileObject> sampleFiles =
          await bucket.list(path: 'sample-pool/${folder.name}');
      for (FileObject file in sampleFiles) {
        if (file.name != '.emptyFolderPlaceholder') {
          String url = await bucket.createSignedUrl(
              'sample-pool/${folder.name}/${file.name}', 1000 * 1000 * 1000);
          samples.add(Sample(folder.name, file.name, url));
        }
      }
    }
  }
  samples.forEach((sample) =>
      {print(sample.artist), print(sample.title), print(sample.url)});
  return samples;
}
