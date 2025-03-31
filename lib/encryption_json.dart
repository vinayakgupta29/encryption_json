import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encryption_json/model.dart';
import 'package:encryption_json/web_security.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// add the `encrypt` package to the app if not already.
// copy this class in other apps and every other API calls
// implementation of this can be read in
// lib/src/features/auth/data/auth_functions.dart 206:222

class Encryption {
  static EncKey? _userKey;
  static EncKey? get getUserKey => _userKey;
  static set setUserKey(EncKey? k) {
    _userKey = k;
  }

  static init(String? keyFile) {
    kIsWeb
        ? WebSecurity.initWebSecurityMode(
          keyFile?.isNotEmpty ?? false ? keyFile : null,
        )
        : null;
  }

  static void storeKey(EncKey k) async {
    String key = json.encode(k.toJson());
    debugPrint("Storekey  $key");
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    prefs.setString("enckey", key);
  }

  static Future<EncKey?> fetchKey() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    String? key = await prefs.getString("enckey");
    debugPrint("Fetchkey  $key");
    return key != null ? EncKey.fromJson(jsonDecode(key)) : null;
  }

  static EncResponse decodeEncResponse(String input) {
    List d0 = input.split("%%");
    debugPrint(d0.toString());
    return EncResponse(keyData: EncKey(key: d0[0], iv: d0[2]), data: d0[1]);
  }

  static Uint8List base64ToByteArr(String str) {
    return base64.decode(str);
  }

  static String encodeBase64(String str) {
    return base64.encode(utf8.encode(str));
  }

  static String encryptAES({
    required String dataBase64,
    required String keyBase64,
    required String iv,
  }) {
    try {
      final fixedIv = iv;
      final dataBytes = base64Decode(dataBase64);
      final keyBytes = encrypt.Key(base64Decode(keyBase64));
      final ivBytes = encrypt.IV(base64Decode(fixedIv));
      // Pad the dataBytes to ensure the length is a multiple of 16
      final padding = 16 - (dataBytes.length % 16);
      final paddedDataBytes = List<int>.from(dataBytes)
        ..addAll(List.filled(padding, padding));
      final encrypter = encrypt.Encrypter(
        encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc),
      );
      final encryptedBytes = encrypter.encryptBytes(
        paddedDataBytes,
        iv: ivBytes,
      );
      return base64Encode(encryptedBytes.bytes);
    } catch (e) {
      throw Exception("Encryption failed: $e");
    }
  }

  static String decryptAES({
    required String dataBase64,
    required String keyBase64,
    required String iv,
  }) {
    try {
      // The fixed IV to ensure deterministic results
      final fixedIV = iv; // Should be 16 bytes for AES-128

      // Decode the Base64-encoded encrypted string
      final encryptedBytes = base64Decode(dataBase64);

      // Create the AES decryption encrypter using CBC mode with the fixed IV
      final keyBytes = encrypt.Key(base64Decode(keyBase64));
      final ivBytes = encrypt.IV(base64Decode(fixedIV));
      final encrypter = encrypt.Encrypter(
        encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc),
      );

      // Decrypt the ciphertext
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedBytes),
        iv: ivBytes,
      );
      // Handle padding: remove padding based on the last byte value
      final padding = decryptedBytes.last;
      final plaintextBytes = decryptedBytes.sublist(
        0,
        decryptedBytes.length - padding,
      );

      // Convert decrypted bytes to a UTF-8 string
      final decryptedString = utf8.decode(plaintextBytes);
      return decryptedString;
    } catch (e) {
      throw Exception("Decryption failed: $e");
    }
  }

  static Map<String, dynamic> transformObject({
    required Map<String, dynamic> obj,
    required String Function({
      required String dataBase64,
      required String keyBase64,
      required String iv,
    })
    function,
    required String k,
    required String iv,
    required List<String> excludedKeys,
    required List<String> hashKeys,
    bool mode = false,
  }) {
    debugPrint("transformObject $obj");
    Map<String, dynamic> transformedObj = {};
    obj.forEach((key, value) {
      if (excludedKeys.contains(key)) {
        transformedObj[key] = value;
      } else if (hashKeys.contains(key)) {
        transformedObj[key] = value;
      } else if (null == value || "" == value) {
        transformedObj[key] = value;
      } else if (value.runtimeType == String) {
        transformedObj[key] = function(dataBase64: value, keyBase64: k, iv: iv);
      } else if (value.runtimeType == List) {
        for (var element in (value as List)) {
          transformedObj[key] = function(
            dataBase64: element,
            keyBase64: k,
            iv: iv,
          );
        }
      } else if (value.runtimeType == Map) {
        transformedObj[key] = transformObject(
          obj: value as Map<String, dynamic>,
          function: function,
          k: k,
          iv: iv,
          excludedKeys: excludedKeys,
          hashKeys: hashKeys,
          mode: mode,
        );
      } else {
        transformedObj[key] = value;
      }
    });
    debugPrint("transformedObj $transformedObj");
    return transformedObj;
  }
}
