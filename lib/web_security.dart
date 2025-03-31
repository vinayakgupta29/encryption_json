import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:flutter/services.dart' show rootBundle;

class WebSecurity {
  static final List<String> _requiredSequence = [
    'control',
    'alt',
    's',
    'd',
    'k',
  ];
  static final List<String> _disableSequence = [
    'control',
    'alt',
    's',
    'f',
    'k',
  ];
  String? securityMode = web.window.localStorage.getItem(securityModeKey);

  static List<String> keyPresses = [];

  static String securityModeKey = "securityMode";
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
    keyPresses.add(keyPressed);

    // If the sequence is incorrect, reset the list
    if (keyPresses.length > _requiredSequence.length) {
      keyPresses.removeAt(0);
    }

    // Check if the sequence matches
    if (keyPresses.length == _requiredSequence.length &&
        keyPresses.asMap().entries.every((entry) {
          int index = entry.key;
          String key = entry.value;
          return key == _requiredSequence[index];
        })) {
      enableSecurityMode();
      keyPresses.clear(); // Reset after correct sequence
    } else if (keyPresses.length == _disableSequence.length &&
        keyPresses.asMap().entries.every((entry) {
          int index = entry.key;
          String key = entry.value;
          return key == _disableSequence[index];
        })) {
      disableSecurityMode();
      keyPresses.clear();
    }
    print("keypress called $keyPressed $event");
  }

  static void enableSecurityMode() {
    // Set the flag in localStorage to enable security mode
    web.window.localStorage.setItem(securityModeKey, 'true');

    // Redirect to the security tutorial (or whatever is required)
    _redirectToSecurityDemo();
  }

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
    web.document.body?.appendChild(iframe); // Optionally clear the body

    // Optionally, add additional styling to make the iframe fullscreen
    iframe.style.position = 'absolute';
    iframe.style.top = '0';
    iframe.style.left = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';

    iframe.onLoad.listen((event) {
      // Ensure the video is playing
      Timer(Duration(milliseconds: 500), () {
        iframe.contentWindow?.postMessage(
          '{"event":"command","func":"playVideo"}'.toJS,
          '*'.toJS,
        );
      });
      // Wait a bit to ensure iframe is fully loaded before sending the command
    });
  }
}


//<iframe width="560" height="315" src="https://www.youtube.com/embed/?si=v9eLXpno3fB6RsSd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>