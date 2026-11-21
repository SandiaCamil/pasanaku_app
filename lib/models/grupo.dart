class Frecuencia {
  static const semanal = 'semanal';
  static const quincenal = 'quincenal';
  static const mensual = 'mensual';
  static const todas = [semanal, quincenal, mensual];
}

class Grupo {
  final int? id;
  final String nombre;
  final double monto;
  final String frecuencia;
  final DateTime fechaInicio;
  final int rondaActual;
  final int totalRondas;
  final bool finalizado;

  const Grupo({
    this.id,
    required this.nombre,
    required this.monto,
    required this.frecuencia,
    required this.fechaInicio,
    this.rondaActual = 1,
    required this.totalRondas,
    this.finalizado = false,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'monto': monto,
    'frecuencia': frecuencia,
    'fecha_inicio': fechaInicio.toIso8601String(),
    'ronda_actual': rondaActual,
    'total_rondas': totalRondas,
    'finalizado': finalizado ? 1 : 0,
  };

  factory Grupo.fromMap(Map<String, Object?> m) => Grupo(
    id: m['id'] as int?,
    nombre: m['nombre'] as String,
    monto: (m['monto'] as num).toDouble(),
    frecuencia: m['frecuencia'] as String,
    fechaInicio: DateTime.parse(m['fecha_inicio'] as String),
    rondaActual: m['ronda_actual'] as int,
    totalRondas: m['total_rondas'] as int,
    finalizado: (m['finalizado'] as int) == 1,
  );
}