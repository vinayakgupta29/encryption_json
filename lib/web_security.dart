import 'package:web/web.dart' as web;
import 'package:flutter/services.dart' show rootBundle;

class WebSecurity {
  // static final List<String> _requiredSequence = [
  //   'control',
  //   'alt',
  //   's',
  //   'd',
  //   'k',
  // ];
  String? securityMode = web.window.localStorage.getItem(securityModeKey);

  static List<String> _keyPresses = [];

  static String securityModeKey = 'securityMode';
  static initWebSecurityMode(String? keyFile) async {
    bool b =
        (await rootBundle.loadString(
          keyFile ?? "packages/encryption_json/assets/keys/auth_key.pem",
        )).isNotEmpty;

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
    List enableSequence = ['control', 'alt', 'f', 'd', 'k'];
    List disableSequence = ['control', 'alt', 's', 'd', 'f'];
    // Set up an event listener for the keydown event
    web.window.onKeyDown.listen((web.KeyboardEvent event) {
      // Push the key pressed to the _keyPresses list
      _keyPresses.add(event.code);

      // Check if the current key sequence matches the enable sequence
      if (_keyPresses.length >= enableSequence.length) {
        // If keys match the enable sequence, enable security mode
        if (_keyPresses
                .sublist(_keyPresses.length - enableSequence.length)
                .join() ==
            enableSequence.join()) {
          enableSecurityMode();
        }
      }

      // Check if the current key sequence matches the disable sequence
      if (_keyPresses.length >= disableSequence.length) {
        // If keys match the disable sequence, disable security mode
        if (_keyPresses
                .sublist(_keyPresses.length - disableSequence.length)
                .join() ==
            disableSequence.join()) {
          disableSecurityMode();
        }
      }
    });
    print("keypress called $keyPressed $event");
  }

  // Function to enable security mode via keybinding (Ctrl+Alt+S+D+K)
  static void enableSecurityMode() {
    // Set the flag in localStorage to enable security mode
    web.window.localStorage.setItem(securityModeKey, 'true');

    // Redirect to the security tutorial (or whatever is required)
    _redirectToSecurityDemo();
  }

  // Function to disable security mode via keybinding (Alt+Shift+K+I)
  static void disableSecurityMode() {
    // Remove the security mode flag from localStorage
    web.window.localStorage.removeItem(securityModeKey);

    // Go back to the app or perform other necessary operations
    print("Exiting security mode. Returning to the main app...");
  }

  static void _redirectToSecurityDemo() {
    print("redirectCalled");
    // Define the URL for the YouTube video with autoplay and fullscreen
    String url = 'https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1&fs=1';

    web.HTMLIFrameElement iframe =
        web.HTMLIFrameElement()
          ..width =
              '100%' // Adjust the width as needed
          ..height =
              '100%' // Adjust the height as needed
          ..src = url
          ..style.border = 'none';

    // Replace the body or a specific container with the iframe to show the video
    web.document.body?.innerHTML = iframe; // Optionally clear the body

    // Optionally, add additional styling to make the iframe fullscreen
    iframe.style.position = 'absolute';
    iframe.style.top = '0';
    iframe.style.left = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';
  }
}


//<iframe width="560" height="315" src="https://www.youtube.com/embed/?si=v9eLXpno3fB6RsSd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>