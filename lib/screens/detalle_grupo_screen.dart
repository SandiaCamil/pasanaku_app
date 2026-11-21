import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grupo.dart';
import '../providers/detalle_grupo_provider.dart';

class DetalleGrupoScreen extends StatefulWidget {
  final Grupo grupo;
  const DetalleGrupoScreen({super.key, required this.grupo});

  @override
  State<DetalleGrupoScreen> createState() => _DetalleGrupoScreenState();
}

class _DetalleGrupoScreenState extends State<DetalleGrupoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<DetalleGrupoProvider>().cargarGrupo(widget.grupo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final det = context.watch<DetalleGrupoProvider>();
    final g = det.grupo ?? widget.grupo;
    final pozoTotal = g.monto * det.participantes.length;
    final recaudado = g.monto * det.pagosRonda.length;
    final receptor = det.receptorTurnoActual;

    return Scaffold(
      appBar: AppBar(
        title: Text(g.nombre),
        actions: [
          if (!g.finalizado &&
              g.rondaActual == 1 &&
              det.pagosRonda.isEmpty &&
              det.participantes.length > 1)
            IconButton(
              tooltip: 'Sortear turnos',
              icon: const Icon(Icons.shuffle),
              onPressed: () async {
                await det.sortearTurnos();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('¡Turnos sorteados aleatoriamente!')),
                  );
                }
              },
            ),
        ],
      ),
      body: det.cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.finalizado
                        ? '¡Pasanaku Finalizado!'
                        : 'Ronda ${g.rondaActual} de ${g.totalRondas}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (receptor != null)
                    Text(
                      'Recibe el pozo: ${receptor.nombre} (Turno #${receptor.turno})',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Recaudado: Bs ${recaudado.toStringAsFixed(2)} / Bs ${pozoTotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: pozoTotal > 0 ? recaudado / pozoTotal : 0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aportes de la ronda (toca para marcar pago):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          for (final p in det.participantes)
            Card(
              child: CheckboxListTile(
                value: det.yaPago(p.id!),
                onChanged: g.finalizado
                    ? null
                    : (_) async {
                  try {
                    await det.alternarPago(p);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'No se pudo registrar el pago.')),
                      );
                    }
                  }
                },
                secondary: CircleAvatar(child: Text('${p.turno}')),
                title: Text(p.nombre),
                subtitle: Text(
                  p.turno == det.turnoEnCurso
                      ? 'Turno de cobro en esta ronda · Bs ${g.monto.toStringAsFixed(2)}'
                      : 'Cuota: Bs ${g.monto.toStringAsFixed(2)}',
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (!g.finalizado)
            FilledButton.icon(
              onPressed: det.todosPagaron ? det.avanzarRonda : null,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                g.rondaActual >= g.totalRondas
                    ? 'Finalizar Pasanaku'
                    : 'Cerrar Ronda ${g.rondaActual} y Avanzar',
              ),
            ),
        ],
      ),
    );
  }
}