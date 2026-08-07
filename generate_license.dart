import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() {
  const String salt = "OIL_MASTER_PRO_SECRET";

  print('=============================================');
  print('   OilMaster Pro - License Key Generator');
  print('=============================================');
  stdout.write('Enter Shop Name (as in settings): ');
  
  String? shopName = stdin.readLineSync(encoding: utf8);

  if (shopName == null || shopName.trim().isEmpty) {
    print('Error: Shop name cannot be empty!');
    return;
  }

  shopName = shopName.trim();
  
  // Algorithm: md5(shopName + salt)
  var bytes = utf8.encode(shopName + salt);
  String key = md5.convert(bytes).toString().toUpperCase().substring(0, 16);

  print('\n---------------------------------------------');
  print('Shop Name: $shopName');
  print('License Key: $key');
  print('---------------------------------------------');
  print('Copy and paste this key into the activation screen.');
}
