import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _marcadores = [];
  final TextEditingController _direccionController = TextEditingController();

  // Coordenada inicial del mapa
  final LatLng _centroMapa = LatLng(-34.6037, -58.3816); // Buenos Aires, AR

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa de Ventas")),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _direccionController,
                    decoration: InputDecoration(
                      labelText: "Buscar dirección",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _buscarDireccion,
                ),
              ],
            ),
          ),

          // Mapa interactivo
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centroMapa,
                initialZoom: 13,
                onTap: (tapPosition, latLng) {
                  _agregarMarcador(latLng);
                },
              ),
              children: [
                // Capa del mapa
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),

                // Marcadores
                MarkerLayer(markers: _marcadores),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Agregar un marcador en la ubicación seleccionada
  void _agregarMarcador(LatLng latLng) {
    setState(() {
      _marcadores.add(
        Marker(
          point: latLng,
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, size: 40, color: Colors.red),
        ),
      );

      // Mover la vista del mapa al nuevo marcador
      _mapController.move(latLng, _mapController.camera.zoom);
    });
  }

  // Buscar dirección usando la API de OpenStreetMap (Nominatim)
  Future<void> _buscarDireccion() async {
    String direccion = _direccionController.text.trim();
    if (direccion.isEmpty) return;

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
        LatLng ubicacion = LatLng(lat, lon);

        _agregarMarcador(ubicacion);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Dirección no encontrada")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al buscar dirección")),
      );
    }
  }
}
