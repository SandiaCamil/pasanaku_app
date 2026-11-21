import 'package:flutter/foundation.dart';
import '../data/pasanaku_repositorio.dart';
import '../models/grupo.dart';
import '../models/participante.dart';

class GruposProvider extends ChangeNotifier {
  final PasanakuRepositorio _repo;
  GruposProvider(this._repo);

  List<Grupo> _grupos = [];
  bool _cargando = false;
  String? _error;

  List<Grupo> get grupos => _grupos;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _grupos = await _repo.obtenerGrupos();
    } catch (_) {
      _error = 'No se pudieron cargar los grupos';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> crear(Grupo grupo, List<Participante> participantes) async {
    await _repo.crearGrupo(grupo, participantes);
    await cargar();
  }

  Future<void> eliminar(int grupoId) async {
    await _repo.eliminarGrupo(grupoId);
    await cargar();
  }
}