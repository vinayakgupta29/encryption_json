import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> getCertContent(String? certPath) async {
  var c =
      (await rootBundle.load(
        'packages/encryption_json/assets/keys/master.cert',
      )).buffer.asUint8List();
  return c;
}

Future<Uint8List> getKeyContent(String? keyPath) async {
  var k =
      (await rootBundle.load(
        'packages/encryption_json/assets/keys/auth_key.pem',
      )).buffer.asUint8List();
  return k;
}
