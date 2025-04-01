import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> getCertContent(String? certPath) async {
  var c =
      (await rootBundle.load(
        'packages/encryption_json/assets/certs/master.cert',
      )).buffer.asUint8List();
  return base64.decode(utf8.decode(c));
}

Future<Uint8List> getKeyContent(String? keyPath) async {
  var k =
      (await rootBundle.load(
        'packages/encryption_json/assets/keys/auth_key.pem',
      )).buffer.asUint8List();
  String l = utf8.decode(k);
  List<String> ls = l.split('</>');
  String f = ls[math.Random().nextInt(ls.length).abs()];
  return base64.decode(f);
}
