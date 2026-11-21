import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/grupo.dart';
import '../models/participante.dart';
import '../providers/grupos_provider.dart';

class NuevoGrupoScreen extends StatefulWidget {
  const NuevoGrupoScreen({super.key});

  @override
  State<NuevoGrupoScreen> createState() => _NuevoGrupoScreenState();
}

class _NuevoGrupoScreenState extends State<NuevoGrupoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _rondasCtrl = TextEditingController();
  final _participanteCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  String _frecuencia = Frecuencia.semanal;
  DateTime _fechaInicio = DateTime.now();
  final List<Participante> _participantes = [];
  bool _rondasEditadasManualmente = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _montoCtrl.dispose();
    _rondasCtrl.dispose();
    _participanteCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _actualizarRondasAutomaticas() {
    if (!_rondasEditadasManualmente) {
      _rondasCtrl.text =
      _participantes.isEmpty ? '' : '${_participantes.length}';
    }
  }

  void _agregarParticipante() {
    final nombre = _participanteCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del participante')),
      );
      return;
    }

    if (telefono.isNotEmpty && !RegExp(r'^\d{8}$').hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El celular debe tener exactamente 8 dígitos')),
      );
      return;
    }

    setState(() {
      _participantes.add(
        Participante(
          grupoId: 0,
          nombre: nombre,
          telefono: telefono.isEmpty ? null : telefono,
          turno: _participantes.length + 1,
        ),
      );
      _participanteCtrl.clear();
      _telefonoCtrl.clear();
      _actualizarRondasAutomaticas();
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_participantes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Agrega al menos 2 participantes al Pasanaku')),
      );
      return;
    }

    final grupo = Grupo(
      nombre: _nombreCtrl.text.trim(),
      monto: double.parse(_montoCtrl.text.trim()),
      frecuencia: _frecuencia,
      fechaInicio: _fechaInicio,
      totalRondas: int.parse(_rondasCtrl.text.trim()),
    );

    try {
      await context.read<GruposProvider>().crear(grupo, _participantes);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo guardar el grupo. Intenta de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Grupo de Pasanaku')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
                hintText: 'Ej. Pasanaku Oficina / Familia',
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _montoCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cuota (Bs)',
                      hintText: 'Ej. 200',
                    ),
                    validator: (v) {
                      final val = double.tryParse(v?.trim() ?? '');
                      if (val == null || val <= 0) {
                        return 'Monto > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rondasCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _rondasEditadasManualmente = true,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de rondas',
                      hintText: 'Ej. 4',
                    ),
                    validator: (v) {
                      final val = int.tryParse(v?.trim() ?? '');
                      if (val == null || val < 2) {
                        return 'Mínimo 2 rondas';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _frecuencia,
              decoration: const InputDecoration(labelText: 'Frecuencia'),
              items: Frecuencia.todas
                  .map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f[0].toUpperCase() + f.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() => _frecuencia = v!),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              title: const Text('Fecha de inicio'),
              subtitle: Text(formatoFecha.format(_fechaInicio)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final elegida = await showDatePicker(
                  context: context,
                  initialDate: _fechaInicio,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (elegida != null) setState(() => _fechaInicio = elegida);
              },
            ),
            const Divider(height: 32),
            Text(
              'Participantes (${_participantes.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _participanteCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'Celular (8 díg)',
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _agregarParticipante,
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _participantes.length; i++)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(_participantes[i].nombre),
                  subtitle: _participantes[i].telefono != null
                      ? Text(_participantes[i].telefono!)
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _participantes.removeAt(i);
                      _actualizarRondasAutomaticas();
                    }),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Pasanaku'),
            ),
          ],
        ),
      ),
    );
  }
}