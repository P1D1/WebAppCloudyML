import 'package:encrypt/encrypt.dart';

String? encryption(String url) {
  final key = Key.fromBase64('mfayobMFA0NibIcPam7G/CojMigxAsnFB66WUnW4PKw=');
  final iv = IV.fromBase64('mfayobMFA0NibIcPam7G/CojMigxAsnFB66WUnW4PKw=');

  final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(url, iv: iv);


  return encrypted.base64;
}

String decryption(String url) {

  final key = Key.fromBase64('mfayobMFA0NibIcPam7G/CojMigxAsnFB66WUnW4PKw=');
  final iv = IV.fromBase64('mfayobMFA0NibIcPam7G/CojMigxAsnFB66WUnW4PKw=');

  final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
  final decrypted = encrypter.decrypt(Encrypted.from64(url), iv: iv);

  return decrypted;
}