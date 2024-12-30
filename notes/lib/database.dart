import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databases extends ChangeNotifier {
  static Database? _db;
  List<Map<String, dynamic>> notes = [];
  
  Databases({required this.notes});

  Future<Database?> get db async {
    _db ??= await createDB();
    return _db;
  }

  Future<Database> createDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "notes.db");
    return openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 1,
      onOpen: _onOpen,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("onUpgrade =====================================");
  }

  Future<void> _onOpen(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("PRAGMA foreign_keys = ON");

    await db.execute('''
      CREATE TABLE "Notesmodel" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "titre" TEXT,
        "note" TEXT,
        "date" DATETIME
      )
    ''');

    print("notes created");
    print(" onCreate =====================================");
  }

  Future<void> readData() async {
    Database? mydb = await db;
    List<Map<String, dynamic>> resultat = await mydb!.query("Notesmodel");
    notes = resultat;
  
    notifyListeners();
  }

  void filterNotes(query) {
      notes = notes.where((note){
      return  note['titre'].toLowerCase().contains(query) ||
            note["note"].toLowerCase().contains(query);
      }).toList();
    notifyListeners();
  }

  Future<void> insertData(String title, String content, String date) async {
    Database? mydb = await db;
    await mydb!.insert(
      'Notesmodel',
      {
        'titre': title,
        'note': content,
        'date': date,
      },
    );
    readData();
  }

  Future<void> updateData(String title, String content, int id) async {
    Database? mydb = await db;
    await mydb!.update(
      'Notesmodel',
      {
        'titre': title,
        'note': content,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    readData();
  }

  Future<void> deleteData(int id) async {
    Database? mydb = await db;
    await mydb!.delete(
      'Notesmodel',
      where: 'id = ?',
      whereArgs: [id],
    );
    readData();
  }
}

final databaseme = ChangeNotifierProvider<Databases>((ref) {
  return Databases(notes: []);
});
