import '../models/grupo.dart';
import '../models/participante.dart';
import '../models/pago.dart';
import 'base_datos.dart';

class PasanakuRepositorio {
  final BaseDatos _bd = BaseDatos.instancia;

  // ---------- Grupos ----------
  Future<int> crearGrupo(Grupo grupo, List<Participante> participantes) async {
    final db = await _bd.db;
    return db.transaction((txn) async {
      final grupoId = await txn.insert('grupos', grupo.toMap()..remove('id'));
      for (var i = 0; i < participantes.length; i++) {
        final p = participantes[i].copyWith(grupoId: grupoId, turno: i + 1);
        await txn.insert('participantes', p.toMap()..remove('id'));
      }
      return grupoId;
    });
  }

  Future<List<Grupo>> obtenerGrupos() async {
    final db = await _bd.db;
    final filas = await db.query('grupos', orderBy: 'id DESC');
    return filas.map(Grupo.fromMap).toList();
  }

  Future<void> actualizarRonda(int grupoId, int ronda,
      {bool finalizado = false}) async {
    final db = await _bd.db;
    await db.update(
      'grupos',
      {'ronda_actual': ronda, 'finalizado': finalizado ? 1 : 0},
      where: 'id = ?',
      whereArgs: [grupoId],
    );
  }

  Future<void> eliminarGrupo(int grupoId) async {
    final db = await _bd.db;
    await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);
  }

  // ---------- Participantes ----------
  Future<List<Participante>> obtenerParticipantes(int grupoId) async {
    final db = await _bd.db;
    final filas = await db.query(
      'participantes',
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
      orderBy: 'turno',
    );
    return filas.map(Participante.fromMap).toList();
  }

  Future<void> sortearTurnos(int grupoId) async {
    final db = await _bd.db;
    final lista = await obtenerParticipantes(grupoId);
    lista.shuffle();
    await db.transaction((txn) async {
      for (var i = 0; i < lista.length; i++) {
        await txn.update(
          'participantes',
          {'turno': i + 1},
          where: 'id = ?',
          whereArgs: [lista[i].id],
        );
      }
    });
  }

  // ---------- Pagos ----------
  Future<List<Pago>> obtenerPagos(int grupoId, int ronda) async {
    final db = await _bd.db;
    final filas = await db.query(
      'pagos',
      where: 'grupo_id = ? AND ronda = ?',
      whereArgs: [grupoId, ronda],
    );
    return filas.map(Pago.fromMap).toList();
  }

  Future<void> registrarPago(Pago pago) async {
    final db = await _bd.db;
    await db.insert('pagos', pago.toMap()..remove('id'));
  }

  Future<void> anularPago(int participanteId, int ronda) async {
    final db = await _bd.db;
    await db.delete(
      'pagos',
      where: 'participante_id = ? AND ronda = ?',
      whereArgs: [participanteId, ronda],
    );
  }
}