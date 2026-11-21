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
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE grupos ADD COLUMN total_rondas INTEGER NOT NULL DEFAULT 2',
          );
        }
      },
      onCreate: (db, version) async {
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
          CREATE TABLE pagos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            grupo_id INTEGER NOT NULL,
            participante_id INTEGER NOT NULL,
            ronda INTEGER NOT NULL,
            monto REAL NOT NULL,
            fecha_pago TEXT NOT NULL,
            FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE,
            FOREIGN KEY (participante_id) REFERENCES participantes(id) ON DELETE CASCADE,
            UNIQUE (participante_id, ronda)
          )
        ''');
      },
    );
  }
}