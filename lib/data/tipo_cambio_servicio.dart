import 'dart:convert';
import 'package:http/http.dart' as http;

class TipoCambioServicio {
  //Tasa oficial referencial en Bolivia si no hay conexión a internet
  static const double _tasaRespaldo = 6.96;

  Future<double> obtenerTasaBobUsd() async {
    try {
      final uri = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final respuesta = await http.get(uri).timeout(const Duration(seconds: 5));
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
        final tasas = datos['rates'] as Map<String, dynamic>?;
        final bob = tasas?['BOB'];
        if (bob is num && bob > 0) {
          return bob.toDouble();
        }
      }
    } catch (_) {
      //Si falla la red, devuelve la tasa oficial local
    }
    return _tasaRespaldo;
  }
}