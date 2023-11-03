import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAssistant {
  static final String databaseName = "kisiler_rehber.sqlite";

  static Future<Database> databaseAccess() async {
    String databasePath = join(await getDatabasesPath(), databaseName);

    if (await databaseExists(databaseName)) {
      print("the database already exists, no need to copy");
    } else {
      ByteData data = await rootBundle.load("database/$databaseName");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(databasePath).writeAsBytes(bytes, flush: true);
      print("Database coppied.");
    }

    return openDatabase(databasePath);
  }
}
