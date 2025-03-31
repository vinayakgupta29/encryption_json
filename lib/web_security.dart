import 'dart:io';
import 'package:web/web.dart' as web;

class WebSecurity {
  static final List<String> _requiredSequence = [
    'Control',
    'Alt',
    's',
    'd',
    'k',
  ];
  static List<String> _keyPresses = [];
  static initWebSecurityMode(File keyFile) async {
    bool b = await keyFile.exists();
    if (b) {
      web.window.onKeyDown.listen((key) {
        _handleKeyPress(key);
      });
    }
  }

  static void _handleKeyPress(web.KeyboardEvent event) {
    // Check for the correct key press in the required order
    String keyPressed = event.key.toLowerCase();

    // Add the key to the list of pressed keys
    _keyPresses.add(keyPressed);

    // If the sequence is incorrect, reset the list
    if (_keyPresses.length > _requiredSequence.length) {
      _keyPresses.removeAt(0);
    }

    // Check if the sequence matches
    if (_keyPresses.length == _requiredSequence.length &&
        _keyPresses.asMap().entries.every((entry) {
          int index = entry.key;
          String key = entry.value;
          return key == _requiredSequence[index];
        })) {
      _redirectToSecurityDemo();
      _keyPresses.clear(); // Reset after correct sequence
    }
  }

  static void _redirectToSecurityDemo() {
    // Define the URL for the YouTube video with autoplay and fullscreen
    String url = 'https://www.youtube.com/embed/YOUR_VIDEO_ID?autoplay=1&fs=1';

    // Open the URL in a new window with fullscreen mode
    web.window.open(url, '_blank');
  }
}
