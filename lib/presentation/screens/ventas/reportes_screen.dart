import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<dynamic> ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas(); // Cargar las ventas al inicio
  }

  // Cargar las ventas desde Hive
  Future<void> _cargarVentas() async {
    var ventasBox = await Hive.openBox('ventas');
    setState(() {
      ventas = ventasBox.values.toList(); // Guardar las ventas en la lista
    });
  }

  // Calcular la cantidad total de productos comprados por el cliente
  int _calcularCantidadProductos(List productos) {
    int totalProductos = 0;
    productos.forEach((producto) {
      totalProductos +=
          producto['Cantidad'] as int; // Sumar la cantidad de cada producto
    });
    return totalProductos;
  }

  String _formatearFecha(String fecha) {
    DateTime fechaDate =
        DateTime.parse(fecha); // Convierte la cadena en DateTime
    return DateFormat('dd/MM/yyyy').format(fechaDate); // Formato deseado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reportes de Ventas")),
      body: ventas.isEmpty
          ? Center(child: Text("No hay ventas confirmadas"))
          : ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                var venta = ventas[index];
                int cantidadProductos = _calcularCantidadProductos(
                    venta['productos']); // Calcular la cantidad total

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("Cliente: ${venta['cliente']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cantidad de Productos: $cantidadProductos"),
                        Text(
                          "Total: \$${venta['total']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Text("Fecha: ${_formatearFecha(venta['fecha'])}"),
                  ),
                );
              },
            ),
    );
  }
}
