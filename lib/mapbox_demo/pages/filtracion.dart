import 'package:flutter/material.dart';
import 'lugaresCliente.dart';
import 'MapPreviewPage.dart'; // 👈 mantiene tu flujo

class FiltracionPage extends StatefulWidget {
  const FiltracionPage({super.key});

  @override
  State<FiltracionPage> createState() => _FiltracionPageState();
}

class _FiltracionPageState extends State<FiltracionPage> {
  final TextEditingController _searchController = TextEditingController();

  String filtroPais = "Todos";
  String filtroDepto = "Todos";

  late List<Map<String, dynamic>> _resultados;

  @override
  void initState() {
    super.initState();
    _resultados = lugaresCliente;
  }

  void _filtrarTodo() {
    setState(() {
      _resultados = lugaresCliente.where((lugar) {
        bool coincideBusqueda = lugar['nombre']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());

        bool coincidePais = filtroPais == "Todos" || lugar['pais'] == filtroPais;
        bool coincideDepto = filtroDepto == "Todos" || lugar['departamento'] == filtroDepto;

        return coincideBusqueda && coincidePais && coincideDepto;
      }).toList();
    });
  }

  List<String> obtenerDeptos(String pais) {
    if (pais == "Todos") return ["Todos"];
    return [
      "Todos",
      ...lugaresCliente
          .where((l) => l['pais'] == pais)
          .map((l) => l['departamento'])
          .toSet()
    ];
  }

  @override
  Widget build(BuildContext context) {
    final departamentos = obtenerDeptos(filtroPais);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Ambientes Agrícolas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ------------------------- BUSCADOR -------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _filtrarTodo(),
              decoration: InputDecoration(
                hintText: 'Buscar ambientes, lotes o fincas...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ------------------------- FILTROS -------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _chip("Todos", filtroPais, (v) {
                  filtroPais = v;
                  filtroDepto = "Todos";
                  _filtrarTodo();
                }, colorOn: Colors.green),

                const SizedBox(width: 8),
                _chip("Bolivia", filtroPais, (v) {
                  filtroPais = v;
                  filtroDepto = "Todos";
                  _filtrarTodo();
                }),

                const SizedBox(width: 8),
                _chip("Brasil", filtroPais, (v) {
                  filtroPais = v;
                  filtroDepto = "Todos";
                  _filtrarTodo();
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: filtroDepto,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: departamentos
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            ))
                        .toList(),
                    onChanged: (v) {
                      filtroDepto = v.toString();
                      _filtrarTodo();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ------------------------- LISTA -------------------------
          Expanded(
            child: ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final lugar = _resultados[index];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture, color: Colors.yellow, size: 40),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lugar['nombre'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "${lugar['departamento']} • ${lugar['pais']}",
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          _boton(
                            color: Colors.green,
                            text: "Ver Ubi",
                            onTap: () {
                              Navigator.pop(context, lugar); // ✔ EXACTO COMO ANTES
                            },
                          ),
                          const SizedBox(height: 10),
                          _boton(
                            color: Colors.blue,
                            text: "Ver Mapa",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapPreviewPage(
                                    nombre: lugar['nombre'],
                                    lat: lugar['lat'],
                                    lon: lugar['lon'],
                                    departamento: lugar['departamento'],
                                    pais: lugar['pais'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------- WIDGET CHIP -------------------------
  Widget _chip(String label, String selected, Function(String) onTap,
      {Color colorOn = Colors.black}) {
    bool activo = selected == label;

    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? colorOn : Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ------------------------- BOTÓN -------------------------
  Widget _boton({required Color color, required String text, required Function() onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(90, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }
}
