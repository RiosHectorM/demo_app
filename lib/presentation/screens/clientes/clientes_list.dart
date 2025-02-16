import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/clientes_provider.dart';
import '../../../providers/usuarios_provider.dart';
import 'package:hive/hive.dart';

class ClientesScreen extends StatefulWidget {
  static const name = 'clienteslist';

  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _iconoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  List<dynamic> ventas = [];
  List<String> reportesGenerados = [];

  late Box ventasBox;

  bool isLoading = true; // Para indicar si los datos están cargando

  @override
  void initState() {
    super.initState();
    _openVentasBox();
  }

  Future<void> _openVentasBox() async {
    ventasBox =
        await Hive.openBox('ventas'); // Guarda la referencia en ventasBox
    setState(() {
      ventas = ventasBox.values.toList();
      reportesGenerados = ventas.map((venta) => venta.toString()).toList();
      print(reportesGenerados);
      isLoading = false; // Indica que la carga ha finalizado
    });
  }

  void printVentas() {
    if (ventasBox.isNotEmpty) {
      print("Contenido de ventasBox:");
      for (var key in ventasBox.keys) {
        print('Clave: $key, Valor: ${ventasBox.get(key)}');
      }
    } else {
      print('El box de ventas está vacío.');
    }
  }

  bool clienteEnVentas(String nombreCliente) {
    return ventasBox.values.any((venta) {
      return (venta as Map)['cliente'] == nombreCliente;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientesProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Clientes",
          style: TextStyle(color: colors.inversePrimary),
        ),
        backgroundColor: colors.primary,
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Muestra un loading mientras carga Hive
          : Column(
              children: [
                Expanded(
                  child: provider.clientes.isEmpty
                      ? Center(
                          child: Text(
                            "No hay clientes cargados",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = provider.clientes[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                side: BorderSide(color: colors.outline),
                              ),
                              elevation: 2.0,
                              child: ListTile(
                                onTap: () {
                                  final usuariosProvider =
                                      Provider.of<UsuariosProvider>(context,
                                          listen: false);
                                  final usuarioVendedor =
                                      usuariosProvider.currentUser!.email ??
                                          "Desconocido";

                                  final nombreCliente = cliente.nombre;
                                  final direccionCliente = cliente.direccion;

                                  context.pushNamed(
                                    'productos',
                                    pathParameters: {
                                      'nombreCliente':
                                          Uri.encodeComponent(nombreCliente),
                                      'direccionCliente':
                                          Uri.encodeComponent(direccionCliente),
                                      'usuarioVendedor':
                                          Uri.encodeComponent(usuarioVendedor),
                                    },
                                  );
                                },
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    clienteEnVentas(cliente.nombre)
                                        ? Icon(Icons.point_of_sale_sharp,
                                            color: Colors.green)
                                        : Icon(Icons.local_shipping_outlined,
                                            color: Colors.blue),
                                    SizedBox(width: 50),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cliente.nombre,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          cliente.direccion,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                        Text(cliente.categoria),
                                      ],
                                    )
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _nombreController.text = cliente.nombre;
                                        _direccionController.text =
                                            cliente.direccion;
                                        _categoriaController.text =
                                            cliente.categoria;
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Editar Cliente"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: _nombreController,
                                                  decoration: InputDecoration(
                                                      labelText: "Nombre"),
                                                ),
                                                TextField(
                                                  controller:
                                                      _direccionController,
                                                  decoration: InputDecoration(
                                                      labelText: "Dirección"),
                                                ),
                                                TextField(
                                                  controller:
                                                      _categoriaController,
                                                  decoration: InputDecoration(
                                                      labelText: "Categoría"),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  String nombre =
                                                      _nombreController.text;
                                                  String direccion =
                                                      _direccionController.text;
                                                  String categoria =
                                                      _categoriaController.text;
                                                  if (nombre.isNotEmpty) {
                                                    provider.updateCliente(
                                                        index,
                                                        'nuevo',
                                                        nombre,
                                                        direccion,
                                                        categoria);
                                                    Navigator.pop(context);
                                                    _nombreController.clear();
                                                    _direccionController
                                                        .clear();
                                                    _categoriaController
                                                        .clear();
                                                  }
                                                },
                                                child: Text("Guardar"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () =>
                                          provider.deleteCliente(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddCliente(
              iconoController: _iconoController,
              nombreController: _nombreController,
              direccionController: _direccionController,
              categoriaController: _categoriaController,
              provider: provider,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCliente extends StatelessWidget {
  final TextEditingController iconoController;
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController categoriaController;
  final ClientesProvider provider;

  const AddCliente({
    super.key,
    required this.iconoController,
    required this.nombreController,
    required this.direccionController,
    required this.categoriaController,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Agregar Cliente"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextField(
          //   controller: iconoController,
          //   decoration: InputDecoration(labelText: "Icono"),
          // ),
          TextField(
            controller: nombreController,
            decoration: InputDecoration(labelText: "Nombre"),
          ),
          TextField(
            controller: direccionController,
            decoration: InputDecoration(labelText: "Dirección"),
          ),
          TextField(
            controller: categoriaController,
            decoration: InputDecoration(labelText: "Categoría"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              String icono = iconoController.text;
              String nombre = nombreController.text;
              String direccion = direccionController.text;
              String categoria = categoriaController.text;

              if (nombre.isNotEmpty) {
                provider.addCliente(icono, nombre, direccion, categoria);
                iconoController.clear();
                nombreController.clear();
                direccionController.clear();
                categoriaController.clear();
                Navigator.pop(context); // Cierra la ventana
              }
            },
            child: Text("Agregar Cliente"),
          ),
        ],
      ),
    );
  }
}

//Box<Clientes> get clientesBox => _clientesBox;
