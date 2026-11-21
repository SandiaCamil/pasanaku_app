import 'package:flutter_test/flutter_test.dart';
import 'package:pasanaku_app/models/grupo.dart';

void main() {
  group('Modelo Grupo', () {
    final grupo = Grupo(
      nombre: 'Pasanaku Oficina',
      monto: 200,
      frecuencia: Frecuencia.semanal,
      fechaInicio: DateTime(2026, 12, 1),
      totalRondas: 4,
    );

    test('se convierte a mapa y vuelve con los mismos datos', () {
      final copia = Grupo.fromMap(grupo.toMap());
      expect(copia.nombre, 'Pasanaku Oficina');
      expect(copia.monto, 200);
      expect(copia.frecuencia, Frecuencia.semanal);
      expect(copia.totalRondas, 4);
      expect(copia.rondaActual, 1);
      expect(copia.finalizado, false);
    });

    test('las frecuencias disponibles son tres', () {
      expect(Frecuencia.todas.length, 3);
    });
  });
}