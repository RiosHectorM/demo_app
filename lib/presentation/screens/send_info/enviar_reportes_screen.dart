import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EnviarReportesScreen extends StatefulWidget {
  @override
  _EnviarReportesScreenState createState() => _EnviarReportesScreenState();
}

class _EnviarReportesScreenState extends State<EnviarReportesScreen> {
  String _jsonVentas = "Cargando datos...";
  List<String> _reportesGuardados = [];

  @override
  void initState() {
    super.initState();
    _cargarReporte();
    _cargarReportesGuardados();
  }

  /// Carga las ventas y convierte en JSON
  Future<void> _cargarReporte() async {
    String jsonVentas = await _obtenerReporteJson();
    setState(() {
      _jsonVentas = jsonVentas;
    });
  }

  /// Obtiene el JSON de las ventas almacenadas en Hive
  Future<String> _obtenerReporteJson() async {
    var ventasBox = await Hive.openBox('ventas');
    List<dynamic> ventas = ventasBox.values.toList();
    return jsonEncode(ventas);
  }

  /// Guarda el reporte en Hive con un timestamp único
  Future<void> _guardarReporte() async {
    var reportesBox = await Hive.openBox('reportes');
    String timestamp = DateTime.now().toIso8601String();
    await reportesBox.put(timestamp, _jsonVentas);
    _cargarReportesGuardados();
  }

  /// Carga la lista de reportes guardados en Hive
  Future<void> _cargarReportesGuardados() async {
    var reportesBox = await Hive.openBox('reportes');
    setState(() {
      _reportesGuardados = reportesBox.keys.cast<String>().toList();
    });
  }

  /// Comparte un reporte y lo elimina después
  Future<void> _compartirYEliminarReporte(String clave) async {
    var reportesBox = await Hive.openBox('reportes');
    String reporteJson = reportesBox.get(clave);

    // Comparte el reporte
    await Share.share(reporteJson, subject: "Reporte de Ventas");

    // Después de compartir, lo eliminamos
    var ventasBox = await Hive.openBox('ventas');
    await ventasBox.clear();
    await reportesBox.delete(clave);
    _cargarReportesGuardados();
  }

  /// Envía un reporte por Email y lo elimina después
  Future<void> _enviarPorEmailYEliminar(String clave) async {
    var reportesBox = await Hive.openBox('reportes');
    String reporteJson = reportesBox.get(clave);

    String email =
        "mailto:destinatario@example.com?subject=Reporte de Ventas&body=${Uri.encodeComponent(reporteJson)}";

    if (await canLaunchUrl(Uri.parse(email))) {
      await launchUrl(Uri.parse(email));

      // Después de enviarlo, lo eliminamos
      var ventasBox = await Hive.openBox('ventas');
      await ventasBox.clear();
      await reportesBox.delete(clave);
      _cargarReportesGuardados();
    } else {
      print("No se pudo abrir el correo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enviar Reportes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Vista previa del reporte:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(_jsonVentas, style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _guardarReporte,
              child: Text("Guardar Reporte"),
            ),
            SizedBox(height: 10),
            Text("Reportes Guardados:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _reportesGuardados.length,
                itemBuilder: (context, index) {
                  String clave = _reportesGuardados[index];
                  return ListTile(
                    title: Text("Reporte $clave"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () => _compartirYEliminarReporte(clave),
                        ),
                        IconButton(
                          icon: Icon(Icons.email),
                          onPressed: () => _enviarPorEmailYEliminar(clave),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
