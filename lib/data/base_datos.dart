import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatos {
  BaseDatos._();
  static final BaseDatos instancia = BaseDatos._();

  Future<Database>? _futuro;
  Future<Database> get db => _futuro ??= _abrir();

  Future<String> _ruta() async {
    if (kIsWeb) {
      return 'pasanaku.db';
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return join(await getDatabasesPath(), 'pasanaku.db');
    }
    final dir = await getApplicationSupportDirectory();
    await Directory(dir.path).create(recursive: true);
    return join(dir.path, 'pasanaku.db');
  }

  Future<Database> _abrir() async {
    return openDatabase(
      await _ruta(),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE grupos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            monto REAL NOT NULL CHECK (monto > 0),
            frecuencia TEXT NOT NULL,
            fecha_inicio TEXT NOT NULL,
            ronda_actual INTEGER NOT NULL DEFAULT 1,
            finalizado INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE participantes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            grupo_id INTEGER NOT NULL,
            nombre TEXT NOT NULL,
            telefono TEXT,
            turno INTEGER NOT NULL,
            FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE grupos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            monto REAL NOT NULL CHECK (monto > 0),
            frecuencia TEXT NOT NULL,
            fecha_inicio TEXT NOT NULL,
            ronda_actual INTEGER NOT NULL DEFAULT 1,
            total_rondas INTEGER NOT NULL,
            finalizado INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }
}