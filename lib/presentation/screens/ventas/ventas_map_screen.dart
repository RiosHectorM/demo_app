import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';

class MapaVentasScreen extends StatefulWidget {
  @override
  _MapaVentasScreenState createState() => _MapaVentasScreenState();
}

class _MapaVentasScreenState extends State<MapaVentasScreen> {
  final MapController _mapController = MapController();
  List<Marker> _marcadores = [];

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
          _agregarMarcador(coordenadas, venta['cliente']);
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
      print("Error obteniendo coordenadas: $e");
    }
    return null;
  }

  void _agregarMarcador(LatLng ubicacion, String cliente) {
    setState(() {
      _marcadores.add(
        Marker(
          point: ubicacion,
          width: 40,
          height: 40,
          child: Tooltip(
            message: "Cliente: $cliente",
            child: Icon(Icons.location_on, size: 40, color: Colors.blue),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa de Ventas Realizadas")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(-34.6037, -58.3816), // Buenos Aires
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
