import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';

class MapaVentasScreen extends StatefulWidget {
  const MapaVentasScreen({super.key});

  @override
  _MapaVentasScreenState createState() => _MapaVentasScreenState();
}

class _MapaVentasScreenState extends State<MapaVentasScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _marcadores = [];
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    var ventasBox = await Hive.openBox('ventas');
    List<dynamic> ventas = ventasBox.values.toList();

    for (var venta in ventas) {
      String direccion = venta['direccion'] ?? "";
      if (direccion.isNotEmpty) {
        LatLng? coordenadas = await _obtenerCoordenadas(direccion);
        if (coordenadas != null) {
          int cantidadTotal = 0;
          if (venta['productos'] is List) {
            cantidadTotal = venta['productos']
                .map((producto) => (producto['Cantidad'] ?? 0) as int)
                .reduce((a, b) => a + b);
          } else {
            cantidadTotal = venta['productos']['Cantidad'] ?? 0;
          }

          _agregarMarcador(coordenadas, venta['cliente'], venta['vendedor'],
              venta['total'], cantidadTotal.toString());

          // Si es el primer marcador, guardar su posición y mover el mapa
          if (_initialPosition == null) {
            setState(() {
              _initialPosition = coordenadas;
            });
            _mapController.move(_initialPosition!, 15.0);
          }
        }
      }
    }
  }

  Future<LatLng?> _obtenerCoordenadas(String direccion) async {
    try {
      var response = await Dio().get(
        "https://nominatim.openstreetmap.org/search",
        queryParameters: {
          "q": direccion,
          "format": "json",
        },
      );

      if (response.data.isNotEmpty) {
        double lat = double.parse(response.data[0]["lat"]);
        double lon = double.parse(response.data[0]["lon"]);
        return LatLng(lat, lon);
      }
    } catch (e) {
      throw Exception('Error obteniendo coordenadas: $e');
    }
    return null;
  }

  void _agregarMarcador(LatLng ubicacion, String cliente, String vendedor,
      double importe, String cantidad) {
    setState(() {
      _marcadores.add(
        Marker(
          point: ubicacion,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Detalle de Venta"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Cliente: $cliente"),
                      Text("Vendedor: $vendedor"),
                      Text("Cantidad de Productos: $cantidad"),
                      Text("Importe: \$${importe.toStringAsFixed(2)}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cerrar"),
                    ),
                  ],
                ),
              );
            },
            child: Icon(Icons.location_on, size: 40, color: Colors.blue),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de Ventas Realizadas",
            style: TextStyle(color: colors.inversePrimary)),
        backgroundColor: colors.primary,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initialPosition ??
              LatLng(-34.6037, -58.3816), // Buenos Aires por defecto
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _marcadores),
        ],
      ),
    );
  }
}
