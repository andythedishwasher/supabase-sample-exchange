# supabase-sample-exchange

A sample exchange app written with Flutter and Supabase.

## Who is this for?

- If you are running a music label and you aren't afraid of code, this is a decent way to create a private sample exchange for producers within your network that can be tracked if you need data about where your samples are coming from, for example to calculate track splits for Distrokid publishing.

- If you are in the process of learning either Flutter or Supabase, this is a decent introduction to the potential benefits of working with them together as a stack.

## Project Setup

Clone repo locally and set up a Supabase account. Create a project and fill out the .env file with the project url and anon key found on the API Settings page as single-quoted strings. For the Windows build, you can define your app icon by replacing the file windows/runner/resources/app_icon.png with your own png renamed to match the path. So far, that's the only platform this has been extensively tested on, but deep links are set up for Android. You'll just have to fill in a custom url protocol for the deep links in the main.dart initializer like so for the windows build:

```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (Platform.isWindows) {
    registerProtocol('YOUR-CUSTOM-PROTOCOL');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const SampleExchange());
}
```
For the android build, you will want to use the same scheme in the activity section of android\app\src\main\AndroidManifest.xml like so:

```
<activity
    ...
    <intent-filter>
        ...
        <data android:scheme="YOUR-CUSTOM-PROTOCOL" />
    </intent-filter>
</activity>
```
Be sure to choose a custom protocol that's likely to remain globally unique so that routing conflicts don't arise with other apps that end up assuming the same protocol, i.e. instead of my-label-samples, make it f9we35tu6o9-my-label-samples or some other alphanumeric identifier.

You'll then go to your Supabase console and navigate to the URL Configuration section of the Auth tab. There, you should specify your site url as 'YOUR-CUSTOM-PROTOCOL://'. That causes auth redirects to point at the Login page where all of the automated auth-based routing occurs in the initializer.

IMPORTANT NOTE: This repo is not designed for web deployments. I'll be adding a separate branch for the web version when I get time, but it mainly just involves ditching the uni_links dependency and using a regular oauth redirect instead of the custom scheme. If you want to use both in the same project right now, the way to do it would be to clone the repo again in a separate directory, rename the folder to include _web or some other indicator, then remove all references to uni_links or uni_links_desktop from the pubspec.yaml in the new directory. You will only use this directory for web builds. For Android or Windows builds, use this repo's dependencies the way they are. You would also need to add your browser app's base url to the list of authorized redirects on your Supabase console.

After all that, you should be able to type flutter run and test it out.

# Deploying

This is primarily designed to be used as an internal tool rather than being distributed on an app marketplace since that was my initial use case. For that purpose, you can simply run 
'''
flutter run build windows 
```
or 
```
flutter run build android
```
From there, you can copy the contents of build/windows/runner/release for the windows build or you can find the apk at build/app/outputs/apk/app-release.apk. Either one can be distributed as is to whoever you want to have access to your sample exchange. Obviously since this is an open-source tool, you will need to implement your own internal security procedures when distributing the app. This is primarily meant to be a practical demonstration of this stack's capabilities. If you're going to use it in your own operations, modify it accordingly.

Happy sampling!
