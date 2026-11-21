import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'data/pasanaku_repositorio.dart';
import 'providers/detalle_grupo_provider.dart';
import 'providers/grupos_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => PasanakuRepositorio()),
        ChangeNotifierProvider(
          create: (ctx) =>
          GruposProvider(ctx.read<PasanakuRepositorio>())..cargar(),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              DetalleGrupoProvider(ctx.read<PasanakuRepositorio>()),
        ),
      ],
      child: const PasanakuApp(),
    ),
  );
}