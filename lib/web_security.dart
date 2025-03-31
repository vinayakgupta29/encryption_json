import 'package:web/web.dart' as web;
import 'package:flutter/services.dart' show rootBundle;

class WebSecurity {
  static final List<String> _requiredSequence = [
    'Control',
    'Alt',
    's',
    'd',
    'k',
  ];
  static List<String> _keyPresses = [];
  static initWebSecurityMode(String? keyFile) async {
    bool b =
        (await rootBundle.loadString(
          keyFile ?? "assets/keys/auth_key.pem",
        )).isNotEmpty;
    if (true) {
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
    String url = 'https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1&fs=1';

    // Open the URL in a new window with fullscreen mode
    web.window.open(url, '_blank');
  }
}


//<iframe width="560" height="315" src="https://www.youtube.com/embed/?si=v9eLXpno3fB6RsSd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>