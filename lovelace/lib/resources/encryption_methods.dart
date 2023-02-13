import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:lovelace/resources/storage_methods.dart';
import 'package:pointycastle/export.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class AESkeyMethods {
  StorageMethods storageMethods = StorageMethods();

  Future encryptAES(plainText) async {
    final key = Key.fromSecureRandom(32); // 256-bit key
    final iv = IV.fromSecureRandom(16); // 12-bit iv
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // print(key.base64); // returns value of AES key
    storageMethods.write("key",
        key.base64); // store key in secure storage as base64 encoded String
    storageMethods.write(
        "iv", iv.base64); // store iv in secure storage as base64 encoded String
    return encrypted
        .base64; // return the encrypted data as base64 encoded String
  }

  Future decryptAES(cipherText) async {
    // cipherText argument is in base64 encoded String because it is read from the JSON file
    final secretKey =
        await storageMethods.read("key"); // data read is in base64 String form
    final secretIV = await storageMethods.read("iv");
    // print(secretKey.runtimeType); // return Instance of Key
    final key =
        Key.fromBase64(secretKey); // Decode base64 and convert to Key data type
    final iv =
        IV.fromBase64(secretIV); // Decode base64 and convert to IV data type
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(cipherText),
        iv: iv); // Decode the base64 String and convert to Encrypted data type. Apply the IV and encrypter to Encrypted data type to get plaintext
    return decrypted;
  }
}

class RSAkeyMethods {
  Future receiverPublicPem() async {
    return await rootBundle.loadString('assets/rsa/receiver-public-key.pem');
  }

  Future receiverPrivatePem() async {
    return await rootBundle.loadString('assets/rsa/receiver-private-key.pem');
  }

  Future senderPublicPem() async {
    return await rootBundle.loadString('assets/rsa/sender-public-key.pem');
  }

  Future senderPrivatePem() async {
    return await rootBundle.loadString('assets/rsa/sender-private-key.pem');
  }

  Future encryptRSA(plainText) async {
    final rsaPublicKey =
        RSAKeyParser().parse(await senderPublicPem()) as RSAPublicKey;
    final rsaPrivateKey =
        RSAKeyParser().parse(await senderPrivatePem()) as RSAPrivateKey;

    // print out the keys
    // print(RsaKeyHelper().encodePublicKeyToPemPKCS1(rsaPublicKey)); 
    // print(RsaKeyHelper().encodePrivateKeyToPemPKCS1(rsaPrivateKey));


    Encrypter encrypter = Encrypter(RSA(
        publicKey: rsaPublicKey,
        privateKey: rsaPrivateKey,
        encoding: RSAEncoding.OAEP));
    Encrypted encrypted = encrypter.encrypt(plainText);
    print('Message encrypted successfully!');
    print(encrypted.base64); // data type String
    return encrypted; // return as 'Encrypted' data type
  }

  Future decryptRSA(cipherText) async {
    final rsaPublicKey =
        RSAKeyParser().parse(await senderPublicPem()) as RSAPublicKey;  
    final rsaPrivateKey =
        RSAKeyParser().parse(await senderPrivatePem()) as RSAPrivateKey; 

    Encrypter encrypter = Encrypter(RSA(
        publicKey: rsaPublicKey,
        privateKey: rsaPrivateKey,
        encoding: RSAEncoding.OAEP));
    String decrypted = encrypter.decrypt(cipherText);
    print('Message decrypted successfully!');
    print(decrypted);
    return decrypted;
  }
}
