import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProductosScreen extends StatefulWidget {
  final String nombre;
  final String direccion;
  final String vendedor;

  const ProductosScreen(
      {super.key,
      required this.nombre,
      required this.direccion,
      required this.vendedor});

  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> productosFiltrados = [];
  final TextEditingController _searchController = TextEditingController();
  Map<int, int> carrito = {};

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _searchController.addListener(_filtrarProductos);
  }

  Future<void> _cargarProductos() async {
    var productosBox = await Hive.openBox('productos');

    List<Map<String, dynamic>> listaProductos = productosBox.values
        .map((producto) => Map<String, dynamic>.from(producto))
        .toList();

    setState(() {
      productos = listaProductos;
      productosFiltrados = productos;
    });
  }

  void _filtrarProductos() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      productosFiltrados = productos.where((producto) {
        String nombre = producto['Nombre'].toLowerCase();
        String id = producto['ID'].toString();
        return nombre.contains(query) || id.contains(query);
      }).toList();
    });
  }

  void _eliminarDelCarrito(int idProducto) {
    if (carrito.containsKey(idProducto)) {
      setState(() {
        carrito.remove(idProducto); // Elimina el producto del carrito
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Producto eliminado del carrito'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red),
      );

      Navigator.pop(context); // Cierra el diálogo actual

      Future.delayed(Duration(milliseconds: 300), () {
        if (carrito.isNotEmpty) {
          _mostrarResumenCompra(); // Reabre el resumen si hay productos
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('El producto no está en el carrito'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarResumenCompra() {
    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No hay productos en el carrito'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red),
      );
      return;
    }

    double total = 0;

    List<Widget> listaProductos = carrito.entries.map((entry) {
      var producto = productos.firstWhere(
        (p) => p['ID'] == entry.key,
        orElse: () => {},
      );

      if (producto.isNotEmpty) {
        double subtotal = (producto['Precio'] as double) * entry.value;
        total += subtotal;
        return ListTile(
          title: Text(producto['Nombre']),
          subtitle: Text("Cantidad: ${entry.value} x \$${producto['Precio']}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("\$${subtotal.toStringAsFixed(2)}"),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _eliminarDelCarrito(entry.key); // Pasa el ID como int
                },
              ),
            ],
          ),
        );
      } else {
        return SizedBox(); // Evitar error si el producto no existe
      }
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Resumen de Compra"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...listaProductos,
            Divider(),
            ListTile(
              title:
                  Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text("\$${total.toStringAsFixed(2)}"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              _confirmarCompra(total); // Llama a la función de confirmar compra
            },
            child: Text("Confirmar Compra"),
          )
        ],
      ),
    );
  }

  void _agregarAlCarrito(Map<String, dynamic> producto, int cantidad) {
    int idProducto = producto['ID'];

    setState(() {
      if (carrito.containsKey(idProducto)) {
        carrito[idProducto] = carrito[idProducto]! + cantidad;
      } else {
        carrito[idProducto] = cantidad;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${producto['Nombre']} agregado al carrito'),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.green),
    );
  }

  void _confirmarCompra(double total) async {
    var productosBox = await Hive.openBox('productos');
    var ventasBox = await Hive.openBox('ventas');

    // Disminuir stock de productos
    carrito.forEach((id, cantidad) async {
      var producto = productos.firstWhere(
        (p) => p['ID'] == id,
        orElse: () => {},
      );

      if (producto.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Producto no encontrado en el stock'),
              duration: Duration(milliseconds: 500),
              backgroundColor: Colors.red),
        );
        return;
      }

      // Aquí debes buscar el producto en Hive directamente por el ID
      var productoEnStock = await productosBox.get(id);

      if (productoEnStock == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Producto no encontrado en el stock'),
              duration: Duration(milliseconds: 500),
              backgroundColor: Colors.red),
        );
        return;
      }

      int nuevoStock = productoEnStock['Cantidad'] - cantidad;

      if (nuevoStock >= 0) {
        productoEnStock['Cantidad'] = nuevoStock;
        await productosBox.put(
            id, productoEnStock); // Guardamos el producto actualizado en Hive
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No hay suficiente stock para el producto: ${productoEnStock['Nombre']}'),
              duration: Duration(milliseconds: 500),
              backgroundColor: Colors.red),
        );
        return;
      }
    });

    // Registrar la venta en Hive
    await ventasBox.add({
      'cliente': widget.nombre,
      'vendedor': widget.vendedor,
      'direccion': widget.direccion,
      'productos': carrito.entries
          .map((e) => {
                'ID': e.key,
                'Cantidad': e.value,
              })
          .toList(),
      'total': total,
      'fecha': DateTime.now().toString(),
    });

    // Vaciar el carrito
    setState(() {
      carrito.clear();
    });

    // Refrescar productos (vuelve a cargar la lista de productos)
    await _cargarProductos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Compra confirmada con éxito'),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Productos - Cliente ${widget.nombre}",
          style: TextStyle(color: colors.inversePrimary),
        ),
        backgroundColor: colors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Buscar por ID o Nombre",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: productosFiltrados.isEmpty
                ? Center(child: Text("No hay productos disponibles"))
                : ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      return ListTile(
                        title: Text(producto['Nombre']),
                        subtitle: Text(
                            "Cantidad disponible: ${producto['Cantidad']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("\$${producto['Precio']}"),
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              onPressed: () {
                                _mostrarDialogoCantidad(producto);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (carrito.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _mostrarResumenCompra,
                child: Text("Confirmar Compra"),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoCantidad(Map<String, dynamic> producto) {
    TextEditingController cantidadController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Seleccionar cantidad"),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Cantidad"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                int cantidad = int.tryParse(cantidadController.text) ?? 0;
                if (cantidad > 0 && cantidad <= producto['Cantidad']) {
                  _agregarAlCarrito(producto, cantidad);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("CANTIDAD NO VALIDA"),
                        duration: Duration(milliseconds: 500),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: Text("Agregar"),
            ),
          ],
        );
      },
    );
  }
}
