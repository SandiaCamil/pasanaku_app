class Pago {
  final int? id;
  final int grupoId;
  final int participanteId;
  final int ronda;
  final double monto;
  final DateTime fechaPago;

  const Pago({
    this.id,
    required this.grupoId,
    required this.participanteId,
    required this.ronda,
    required this.monto,
    required this.fechaPago,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'grupo_id': grupoId,
    'participante_id': participanteId,
    'ronda': ronda,
    'monto': monto,
    'fecha_pago': fechaPago.toIso8601String(),
  };

  factory Pago.fromMap(Map<String, Object?> m) => Pago(
    id: m['id'] as int?,
    grupoId: m['grupo_id'] as int,
    participanteId: m['participante_id'] as int,
    ronda: m['ronda'] as int,
    monto: (m['monto'] as num).toDouble(),
    fechaPago: DateTime.parse(m['fecha_pago'] as String),
  );
}