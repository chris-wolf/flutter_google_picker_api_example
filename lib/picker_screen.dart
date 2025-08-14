import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PickerScreen extends StatefulWidget {
  final String accessToken;
  final String apiKey;
  final String appId;
  final String? mimeType;
  final String webUrl;

  const PickerScreen({
    super.key,
    required this.accessToken,
    required this.apiKey,
    required this.appId,
    required this.webUrl,
    this.mimeType,

  });

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'PickerResult',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == "CANCEL") {
            Navigator.pop(context);
            return;
          }
          try {
            final List<dynamic> pickedFiles = jsonDecode(message.message);
            if (pickedFiles.isNotEmpty) {
              Navigator.pop(context, message.message);
            } else {
              Navigator.pop(context);
            }
          } catch (e) {
            debugPrint("Error parsing picker result: $e");
            Navigator.pop(context);
          }
        },
      );

    _loadHtmlFromUrl();
  }

  Future<void> _loadHtmlFromUrl() async {
    // Construct the full URL with parameters first
    final queryParameters = {
      'token': widget.accessToken,
      'apiKey': widget.apiKey,
      'appId': widget.appId,
    };
    if (widget.mimeType != null) {
      queryParameters['mimeType'] = widget.mimeType!;
    }
    final pickerUrlWithParams = Uri.parse(widget.webUrl)
        .replace(queryParameters: queryParameters);

    try {
      // Now, fetch the content FROM THE URL THAT INCLUDES THE PARAMETERS
      final response = await http.get(pickerUrlWithParams);

      if (response.statusCode == 200) {
        // We still provide the base URL for the security context
        await _controller.loadHtmlString(
            response.body,
            baseUrl: pickerUrlWithParams.toString()
        );
      } else {
        throw Exception('Failed to load page: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load Picker: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a File'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // We only show the WebView if there's no error
          if (_error == null)
            WebViewWidget(controller: _controller),
          // Show loading indicator
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          // Show error message if something went wrong
          if (_error != null)
            Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )),
        ],
      ),
    );
  }
}