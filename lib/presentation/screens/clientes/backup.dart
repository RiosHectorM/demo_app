import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../../providers/clientes_provider.dart';
import '../../../providers/usuarios_provider.dart';

class ClientesScreen extends StatelessWidget {
  static const name = 'clienteslist';

  final TextEditingController _iconoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientesProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final ventasBox =
        Hive.box('ventas'); // Abre ventasBox antes de construir la UI

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Clientes",
          style: TextStyle(color: colors.inversePrimary),
        ),
        backgroundColor: colors.primary,
      ),
      body: ValueListenableBuilder(
        valueListenable: ventasBox.listenable(), // Escucha cambios en ventasBox
        builder: (context, Box ventasBox, _) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = provider.clientes[index];

                    bool tieneVentas = ventasBox.containsKey(cliente.nombre);
                    Icon iconoCliente = tieneVentas
                        ? Icon(Icons.point_of_sale_sharp, color: Colors.green)
                        : Icon(Icons.local_shipping_outlined,
                            color: Colors.blue);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(color: colors.outline),
                      ),
                      elevation: 2.0,
                      child: ListTile(
                        onTap: () {
                          final usuariosProvider =
                              Provider.of<UsuariosProvider>(context,
                                  listen: false);
                          final usuarioVendedor =
                              usuariosProvider.currentUser?.email ??
                                  "Desconocido";

                          final nombreCliente = cliente.nombre;
                          final direccionCliente = cliente.direccion;

                          context.goNamed(
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
                            iconoCliente,
                            SizedBox(width: 50),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente.nombre,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  cliente.direccion,
                                  style: TextStyle(fontStyle: FontStyle.italic),
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
                                _iconoController.text = cliente.icono;
                                _nombreController.text = cliente.nombre;
                                _direccionController.text = cliente.direccion;
                                _categoriaController.text = cliente.categoria;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Editar Cliente"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _iconoController,
                                          decoration: InputDecoration(
                                              labelText: "Icono"),
                                        ),
                                        TextField(
                                          controller: _nombreController,
                                          decoration: InputDecoration(
                                              labelText: "Nombre"),
                                        ),
                                        TextField(
                                          controller: _direccionController,
                                          decoration: InputDecoration(
                                              labelText: "Direccion"),
                                        ),
                                        TextField(
                                          controller: _categoriaController,
                                          decoration: InputDecoration(
                                              labelText: "Categoria"),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          String icono = _iconoController.text;
                                          String nombre =
                                              _nombreController.text;
                                          String direccion =
                                              _direccionController.text;
                                          String categoria =
                                              _categoriaController.text;
                                          if (nombre.isNotEmpty) {
                                            provider.updateCliente(index, icono,
                                                nombre, direccion, categoria);
                                            Navigator.pop(context);
                                            _iconoController.clear();
                                            _nombreController.clear();
                                            _direccionController.clear();
                                            _categoriaController.clear();
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
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.deleteCliente(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
          TextField(
            controller: iconoController,
            decoration: InputDecoration(labelText: "Icono"),
          ),
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
