class Participante {
  final int? id;
  final int grupoId;
  final String nombre;
  final String? telefono;
  final int turno;

  const Participante({
    this.id,
    required this.grupoId,
    required this.nombre,
    this.telefono,
    required this.turno,
  });

  Participante copyWith({int? grupoId, int? turno}) => Participante(
    id: id,
    grupoId: grupoId ?? this.grupoId,
    nombre: nombre,
    telefono: telefono,
    turno: turno ?? this.turno,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'grupo_id': grupoId,
    'nombre': nombre,
    'telefono': telefono,
    'turno': turno,
  };

  factory Participante.fromMap(Map<String, Object?> m) => Participante(
    id: m['id'] as int?,
    grupoId: m['grupo_id'] as int,
    nombre: m['nombre'] as String,
    telefono: m['telefono'] as String?,
    turno: m['turno'] as int,
  );
}