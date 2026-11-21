import 'package:flutter/material.dart';
import 'core/tema.dart';
import 'screens/lista_grupos_screen.dart';

class PasanakuApp extends StatelessWidget {
  const PasanakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasanaku App',
      debugShowCheckedModeBanner: false,
      theme: Tema.claro,
      home: const ListaGruposScreen(),
    );
  }
}