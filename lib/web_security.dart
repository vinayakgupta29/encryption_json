import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:encryption_json/js_module.dart';
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
    _redirectToSecurityDemo(f);
  }

  static void disableSecurityMode() {
    // Remove the security mode flag from localStorage
    web.window.localStorage.removeItem(securityModeKey);

    // Go back to the app or perform other necessary operations
    print("Exiting security mode. Returning to the main app...");
  }

  static void _redirectToSecurityDemo(String videoId) {
    // Load YouTube API
    loadYouTubeAPI();

    // Create player container
    final playerContainer =
        web.document.createElement('div') as web.HTMLDivElement
          ..id = 'yt-player-container'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.position = 'absolute'
          ..style.top = '0'
          ..style.left = '0';

    // Create iframe
    final iframe =
        web.document.createElement('iframe') as web.HTMLIFrameElement
          ..id = 'yt-player'
          ..width = '100%'
          ..height = '100%'
          ..src =
              'https://www.youtube.com/embed/$videoId?enablejsapi=1&fs=1&autoplay=1'
          ..style.border = 'none'
          ..allowFullscreen = true;

    playerContainer.appendChild(iframe);

    // Clear existing content
    while (web.document.body?.firstChild != null) {
      web.document.body?.removeChild(web.document.body!.firstChild!);
    }

    web.document.body?.appendChild(playerContainer);

    // Setup callbacks
    jsOnPlayerReady = _onPlayerReady.toJS;
    onYouTubeIframeAPIReady = _onYouTubeIframeAPIReady.toJS;
  }

  static Future<void> handleKeyFetch(String f) async {
    final response = await http.get(Uri.parse(f));
    print(f);
    if (response.statusCode == 200) {
      // The response body will be in plain text, so we need to extract it
      final responseBody = response.body;
      print(responseBody);
      securityMode = int.parse(responseBody) == 0 ? false : true;
      securityMode ?? false ? _redirectToSecurityDemo(f) : null;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}

// Define callbacks outside the class
void _onPlayerReady(JSObject event) {
  try {
    // Safe conversion using JS interop
    final target = event.getProperty('target'.toJS);
    if (target != null) {
      final player = YouTubePlayer.fromJSObject(target);
      player.playVideo();
    }
  } catch (e) {
    print('Error playing video: $e');
    final iframe =
        web.document.getElementById('yt-player') as web.HTMLIFrameElement?;
    if (iframe != null) {
      iframe.src = '${iframe.src}&autoplay=1&mute=1';
    }
  }
}

void _onYouTubeIframeAPIReady() {
  final player = YouTubePlayer(
    'yt-player',
    PlayerOptions(
      playerVars: PlayerVars(
        autoplay: 1,
        mute: 1,
        enablejsapi: 1,
        origin: web.window.location.origin,
      ),
      events: PlayerEvents(onReady: jsOnPlayerReady),
    ),
  );
}
//<iframe width="560" height="315" src="https://www.youtube.com/embed/?si=v9eLXpno3fB6RsSd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>