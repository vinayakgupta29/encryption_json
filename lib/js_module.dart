@JS()
library youtube_iframe_api;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

// Player class
@JS('YT.Player')
class YouTubePlayer {
  external factory YouTubePlayer(String id, [JSObject? options]);

  // Add this factory constructor
  external factory YouTubePlayer.fromJSObject(JSAny jsObject);

  external void playVideo();
  external void pauseVideo();
}

// Options types
extension type PlayerOptions._(JSObject _) implements JSObject {
  external factory PlayerOptions({
    String? height,
    String? width,
    String? videoId,
    PlayerVars? playerVars,
    PlayerEvents? events,
  });
}

extension type PlayerVars._(JSObject _) implements JSObject {
  external factory PlayerVars({
    int? autoplay,
    int? mute,
    int? enablejsapi,
    String? origin,
  });
}

extension type PlayerEvents._(JSObject _) implements JSObject {
  external factory PlayerEvents({
    JSFunction? onReady,
    JSFunction? onStateChange,
  });
}

// Global API functions
@JS('onYouTubeIframeAPIReady')
external set onYouTubeIframeAPIReady(JSFunction callback);

@JS()
external dynamic get YT;

// Helper to load the API
void loadYouTubeAPI() {
  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.src = 'https://www.youtube.com/iframe_api';
  web.document.head!.appendChild(script);
}

// Callback function for player ready
@JS()
external JSFunction get jsOnPlayerReady;

@JS()
external set jsOnPlayerReady(JSFunction fn);
