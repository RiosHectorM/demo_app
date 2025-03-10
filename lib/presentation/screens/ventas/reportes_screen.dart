import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<dynamic> ventas = [];
  List<String> reportesGuardados = [];
  List<String> reportesGenerados = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
    _cargarReportesGuardados();
  }

  // Cargar las ventas desde Hive
  Future<void> _cargarVentas() async {
    var ventasBox = await Hive.openBox('ventas');
    setState(() {
      ventas = ventasBox.values.toList();
      reportesGenerados = ventas.map((venta) => venta.toString()).toList();
    });
  }

  // Cargar los reportes enviados desde 'reportesBox'
  Future<void> _cargarReportesGuardados() async {
    var reportesBox = await Hive.openBox('reportes');
    setState(() {
      reportesGuardados = reportesBox.keys.cast<String>().toList();
    });
  }

  // Calcular la cantidad total de productos comprados por el cliente
  int _calcularCantidadProductos(List productos) {
    int totalProductos = 0;
    for (var producto in productos) {
      totalProductos += producto['Cantidad'] as int;
    }
    return totalProductos;
  }

  // Formatear fecha a dd/MM/yyyy
  String _formatearFecha(String fecha) {
    DateTime fechaDate = DateTime.parse(fecha);
    return DateFormat('dd/MM/yyyy').format(fechaDate);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reportes de Ventas",
          style: TextStyle(color: colors.inversePrimary),
        ),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de Reportes Generados
            ventas.isEmpty
                ? Container()
                : Column(
                    children: [
                      Text(
                        'Reportes Generados',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ventas.length,
                        itemBuilder: (context, index) {
                          var venta = ventas[index];
                          int cantidadProductos =
                              _calcularCantidadProductos(venta['productos']);

                          return FadeInLeft(
                            duration: Duration(milliseconds: 100 + 20 * index),
                            child: Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text("Cliente: ${venta['cliente']}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Cantidad de Productos: $cantidadProductos"),
                                    Text(
                                      "Total: \$${venta['total']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                    "Fecha: ${_formatearFecha(venta['fecha'])}"),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

            // Sección de Reportes Enviados
            reportesGuardados.isEmpty
                ? Container()
                : Column(
                    children: [
                      Text(
                        'Reportes Enviados',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reportesGuardados.length,
                        itemBuilder: (context, index) {
                          String claveReporte = reportesGuardados[index];

                          return FadeInLeft(
                            duration: Duration(milliseconds: 100 + 20 * index),
                            child: Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text("Reporte enviado: $claveReporte"),
                                subtitle: Text(
                                    "Fecha de envío: ${_formatearFecha(claveReporte)}"),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
