import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/tipo_cambio_servicio.dart';
import '../models/grupo.dart';
import '../providers/grupos_provider.dart';
import 'detalle_grupo_screen.dart';
import 'nuevo_grupo_screen.dart';

class ListaGruposScreen extends StatefulWidget {
  const ListaGruposScreen({super.key});

  @override
  State<ListaGruposScreen> createState() => _ListaGruposScreenState();
}

class _ListaGruposScreenState extends State<ListaGruposScreen> {
  double _tasaUsd = 6.96;

  @override
  void initState() {
    super.initState();
    _cargarTasa();
  }

  Future<void> _cargarTasa() async {
    final tasa = await TipoCambioServicio().obtenerTasaBobUsd();
    if (mounted) setState(() => _tasaUsd = tasa);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GruposProvider>();
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasanaku Bolivia'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text('1 USD = ${_tasaUsd.toStringAsFixed(2)} Bs',
                  style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
      body: provider.cargando
          ? const Center(child: CircularProgressIndicator())
          : provider.grupos.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Aún no tienes grupos de Pasanaku',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Toca el botón + para crear un grupo, registrar participantes y sortear los turnos.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.grupos.length,
        itemBuilder: (context, index) {
          final g = provider.grupos[index];
          final equivUsd = g.monto / _tasaUsd;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              title: Row(
                children: [
                  Expanded(
                    child: Text(g.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  if (g.finalizado)
                    const Chip(
                      label: Text('Finalizado',
                          style: TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    Chip(
                      label: Text(
                          'Ronda ${g.rondaActual}/${g.totalRondas}',
                          style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Cuota: Bs ${g.monto.toStringAsFixed(2)} (~US\$ ${equivUsd.toStringAsFixed(2)})\n'
                      'Frecuencia: ${g.frecuencia} · Inicio: ${formatoFecha.format(g.fechaInicio)}',
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmarEliminar(context, g),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleGrupoScreen(grupo: g),
                  ),
                );
                if (context.mounted) {
                  context.read<GruposProvider>().cargar();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NuevoGrupoScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Grupo'),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Tipo de cambio: ExchangeRate-API (exchangerate-api.com)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, Grupo grupo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text('¿Seguro que deseas eliminar "${grupo.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      await context.read<GruposProvider>().eliminar(grupo.id!);
    }
  }
}