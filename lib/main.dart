import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'picker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleSignInAccount? _currentUser;
  String _pickedFileResult = 'No file picked yet.';

  // IMPORTANT: Replace with your actual credentials from the Google Cloud Console
  final String _webClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com'; // e.g., '1234567890-abcdefg.apps.googleusercontent.com'
  final String _appId =
      'YOUR_APP_ID'; // e.g., '1234567890' (This is the numeric part of your client ID)
  final String _apiKey = 'YOUR_API_KEY'; // e.g., 'AIzaSkyr6390df24jey7ox7yn2'
  final String _webUrl =
      'https.your-domain.com/google_picker.html'; // location of the uploaded google_picker.html file

  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      clientId: _webClientId,
      scopes: <String>['https://www.googleapis.com/auth/drive.file'],
    );
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint('Sign in error: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in failed: $error')));
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> _openPicker() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    if (_webClientId == 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' ||
        _apiKey == 'YOUR_API_KEY' ||
        _appId == 'YOUR_APP_ID' ||
        _webUrl == 'https.your-domain.com/google_picker.html') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please update the placeholder credentials in main.dart',
          ),
        ),
      );
      return;
    }

    final authHeaders = await _currentUser!.authHeaders;
    final accessToken = authHeaders['Authorization']!.substring(
      'Bearer '.length,
    );

    // ADD THIS DEBUG CHECK
    debugPrint("--> Access Token: $accessToken");
    debugPrint("--> API Key: $_apiKey");
    debugPrint("--> App ID: $_appId");
    debugPrint("--> Web URL: $_webUrl");

    if (accessToken.isEmpty || _apiKey.isEmpty || _appId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Credentials are not ready.')),
      );
      return;
    }

    // ignore: use_build_context_synchronously
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => PickerScreen(
          accessToken: accessToken,
          apiKey: _apiKey,
          appId: _appId,
          webUrl: _webUrl, // Pass the webUrl
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _pickedFileResult = 'Picker Result:\n$result';
      });
    } else {
      setState(() {
        _pickedFileResult = 'Picker was cancelled or failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Picker Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentUser != null) ...[
              ListTile(
                leading: GoogleUserCircleAvatar(identity: _currentUser!),
                title: Text(_currentUser!.displayName ?? ''),
                subtitle: Text(_currentUser!.email),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openPicker,
                child: const Text('Open Google Drive Picker'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSignOut,
                child: const Text('SIGN OUT'),
              ),
            ] else ...[
              const Text('You are not currently signed in.'),
              ElevatedButton(
                onPressed: _handleSignIn,
                child: const Text('SIGN IN'),
              ),
            ],
            const SizedBox(height: 40),
            const Text(
              'Result from Picker:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_pickedFileResult),
            ),
          ],
        ),
      ),
    );
  }
}
