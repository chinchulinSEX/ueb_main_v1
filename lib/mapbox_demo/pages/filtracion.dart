import 'package:flutter/material.dart';
import 'lugares_ueb.dart';

class FiltracionPage extends StatefulWidget {
  const FiltracionPage({super.key});

  @override
  State<FiltracionPage> createState() => _FiltracionPageState();
}

class _FiltracionPageState extends State<FiltracionPage> {
  final TextEditingController _searchController = TextEditingController();
  String filtroSeleccionado = "Todos";

  final List<Map<String, dynamic>> lugares = lugaresUeb;

  // 🎨 Colores corporativos Suelo & Agua
  static const Color azulAgua = Color(0xFF1565C0);
  static const Color celesteGota = Color(0xFF29B6F6);
  static const Color verdeHoja = Color(0xFF4CAF50);
  static const Color marronSuelo = Color(0xFF6D4C41);

  // 🏷️ Categorías personalizadas
  final List<String> categorias = [
    "Todos",
    "Zonas Agrícolas",
    "Laboratorios",
    "Aulas",
    "Servicios UEB",
    "Comedor / Cafetería",
    "Administración",
    "Entradas y Salidas",
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();

    final lugaresFiltrados = lugares.where((l) {
      final matchTexto = l["nombre"].toLowerCase().contains(query);
      final matchCategoria =
          filtroSeleccionado == "Todos" ? true : l["categoria"] == filtroSeleccionado;
      return matchTexto && matchCategoria;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: azulAgua,
        title: const Text(
          "Buscar puntos - Suelo & Agua",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ⭐⭐⭐ BOTÓN FIJO, BLANCO, Y SEGURO DEL MENÚ DEL TELÉFONO ⭐⭐⭐
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(14),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,       // BLANCO
              foregroundColor: azulAgua,           // AZUL
              elevation: 6,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: azulAgua, width: 2),
              ),
            ),
            onPressed: () => Navigator.pop(context, {"mostrarTodos": true}),
            icon: const Icon(Icons.map, size: 26),
            label: const Text(
              "Mostrar todos los puntos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Buscador
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: celesteGota.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Buscar zonas, puntos o laboratorios...",
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: azulAgua),
              ),
            ),
          ),

          // 🏷️ Chips de Categorías
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: categorias.map((cat) {
                final activo = filtroSeleccionado == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: activo,
                    onSelected: (_) => setState(() => filtroSeleccionado = cat),
                    selectedColor: azulAgua,
                    labelStyle: TextStyle(
                      color: activo ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: azulAgua),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // 📋 Lista de Lugares (CARDS BLANCOS)
          Expanded(
            child: ListView.builder(
              itemCount: lugaresFiltrados.length,
              itemBuilder: (context, index) {
                final l = lugaresFiltrados[index];
                return Card(
                  color: Colors.white, // FONDO BLANCO
                  shadowColor: azulAgua.withOpacity(0.3),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: azulAgua, width: 0.8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                    leading: const Icon(
                      Icons.place,
                      color: azulAgua,
                      size: 36,
                    ),

                    title: Text(
                      l["nombre"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),

                    subtitle: Text(
                      "${l["ubicacion"]} • ${l["categoria"]}",
                      style: const TextStyle(color: Colors.black87),
                    ),

                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeHoja,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          "nombre": l["nombre"],
                          "lat": l["lat"],
                          "lon": l["lon"],
                        });
                      },
                      child: const Text(
                        "Ir",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
