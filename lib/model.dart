class EncKey {
  String key;
  String
      iv; // these both are base 64 String don't do any kind of encoding or decoding to them

  EncKey({required this.key, required this.iv});

  factory EncKey.fromJson(Map<String, dynamic> json) =>
      EncKey(key: json['key'], iv: json['iv']);

  toJson() => {
        'key': key,
        'iv': iv,
      };
}

class EncResponse {
  final EncKey keyData;
  final String data;
  EncResponse({required this.keyData, required this.data});
}
