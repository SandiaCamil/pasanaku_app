import 'package:flutter/foundation.dart';
import '../data/pasanaku_repositorio.dart';
import '../models/grupo.dart';
import '../models/pago.dart';
import '../models/participante.dart';

class DetalleGrupoProvider extends ChangeNotifier {
  final PasanakuRepositorio _repo;
  DetalleGrupoProvider(this._repo);

  Grupo? _grupo;
  List<Participante> _participantes = [];
  List<Pago> _pagosRonda = [];
  bool _cargando = false;

  Grupo? get grupo => _grupo;
  List<Participante> get participantes => _participantes;
  List<Pago> get pagosRonda => _pagosRonda;
  bool get cargando => _cargando;

  bool yaPago(int participanteId) =>
      _pagosRonda.any((p) => p.participanteId == participanteId);

  bool get todosPagaron =>
      _participantes.isNotEmpty &&
          _pagosRonda.length == _participantes.length;

  int get turnoEnCurso {
    if (_grupo == null || _participantes.isEmpty) return 1;
    return ((_grupo!.rondaActual - 1) % _participantes.length) + 1;
  }

  Participante? get receptorTurnoActual {
    if (_grupo == null || _participantes.isEmpty) return null;
    try {
      return _participantes.firstWhere((p) => p.turno == turnoEnCurso);
    } catch (_) {
      return null;
    }
  }

  Future<void> cargarGrupo(Grupo g) async {
    _cargando = true;
    _grupo = g;
    notifyListeners();

    _participantes = await _repo.obtenerParticipantes(g.id!);
    _pagosRonda = await _repo.obtenerPagos(g.id!, g.rondaActual);

    _cargando = false;
    notifyListeners();
  }

  Future<void> sortearTurnos() async {
    if (_grupo == null || _grupo!.rondaActual > 1 || _pagosRonda.isNotEmpty) {
      return;
    }
    await _repo.sortearTurnos(_grupo!.id!);
    _participantes = await _repo.obtenerParticipantes(_grupo!.id!);
    notifyListeners();
  }

  Future<void> alternarPago(Participante participante) async {
    if (_grupo == null || _grupo!.finalizado) return;
    final id = participante.id!;
    if (yaPago(id)) {
      await _repo.anularPago(id, _grupo!.rondaActual);
    } else {
      await _repo.registrarPago(
        Pago(
          grupoId: _grupo!.id!,
          participanteId: id,
          ronda: _grupo!.rondaActual,
          monto: _grupo!.monto,
          fechaPago: DateTime.now(),
        ),
      );
    }
    _pagosRonda = await _repo.obtenerPagos(_grupo!.id!, _grupo!.rondaActual);
    notifyListeners();
  }

  Future<void> avanzarRonda() async {
    if (_grupo == null || !todosPagaron || _grupo!.finalizado) return;
    final esUltima = _grupo!.rondaActual >= _grupo!.totalRondas;
    final nuevaRonda = esUltima ? _grupo!.rondaActual : _grupo!.rondaActual + 1;

    await _repo.actualizarRonda(
      _grupo!.id!,
      nuevaRonda,
      finalizado: esUltima,
    );

    _grupo = Grupo(
      id: _grupo!.id,
      nombre: _grupo!.nombre,
      monto: _grupo!.monto,
      frecuencia: _grupo!.frecuencia,
      fechaInicio: _grupo!.fechaInicio,
      rondaActual: nuevaRonda,
      totalRondas: _grupo!.totalRondas,
      finalizado: esUltima,
    );
    _pagosRonda = await _repo.obtenerPagos(_grupo!.id!, _grupo!.rondaActual);
    notifyListeners();
  }
}