import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Sample {
  String? artist;
  String? title;
  String? url;
  Sample(String this.artist, String this.title, String this.url);
}

Future<String> uploadUserPhoto(SupabaseClient client, User user) async {
  FilePickerResult? selected =
      await FilePicker.platform.pickFiles(type: FileType.image);

  if (selected != null) {
    String extension = selected.files.single.extension!;
    File photoFile = File(selected.files.single.path!);
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
  FilePickerResult? selected =
      await FilePicker.platform.pickFiles(type: FileType.audio);
  if (selected != null) {
    File sampleFile = File(selected.files.single.path!);
    String ext = selected.files.single.extension!;
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

    //imported Realtime notification call goes here

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
  return samples;
}

Future<String> claimSample(
    SupabaseClient client, String artist, String filename) async {
  final bucketPath = 'sample-pool/$artist/$filename';
  final claimedFileBytes =
      await client.storage.from('lsd-media').download(bucketPath);
  final Directory appDocs = await getApplicationDocumentsDirectory();
  final String localPath = Platform.isWindows
      ? '${appDocs.path}\\LSD Samples\\$artist\\$filename'
      : '${appDocs.path}/LSD Samples/$artist/$filename';
  final File claimedFile = File(localPath);
  await claimedFile.create(recursive: true);
  await claimedFile.writeAsBytes(claimedFileBytes);
  await client.storage.from('lsd-media').remove([bucketPath]);
  return localPath;
  //imported Realtime notification call goes here
}
