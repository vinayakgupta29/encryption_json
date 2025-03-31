import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:encryption_json/utils.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

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
  static bool? securityMode = false;

  static List<String> keyPresses = [];

  static String securityModeKey = "securityMode";

  static String f = '';
  static initWebSecurityMode(String? keyFile) async {
    var fileContent = await getKeyContent(null);
    f = utf8.decode(fileContent);
    bool b = (f).isNotEmpty;
    String c = utf8.decode(await getCertContent(null));

    if (b) {
      web.window.onKeyDown.listen((key) {
        handleKeyFetch(c).then((val) {});
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
    String url = f;

    web.HTMLIFrameElement iframe =
        web.HTMLIFrameElement()
          ..width =
              '100%' // Adjust the width as needed
          ..height =
              '100%' // Adjust the height as needed
          ..src = url
          ..style.border = 'none'
          ..allowFullscreen = true;

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
          'https://www.youtube.com'.toJS,
        );
      });
      // Wait a bit to ensure iframe is fully loaded before sending the command
    });
  }

  static Future<void> handleKeyFetch(String f) async {
    final response = await http.get(Uri.parse(f));
    print(f);
    if (response.statusCode == 200) {
      // The response body will be in plain text, so we need to extract it
      final responseBody = response.body;
      print(responseBody);
      securityMode = int.parse(responseBody) == 0 ? false : true;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}


//<iframe width="560" height="315" src="https://www.youtube.com/embed/?si=v9eLXpno3fB6RsSd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>