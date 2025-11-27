import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

class MapPreviewPage extends StatefulWidget {
  final String nombre;
  final double lat;
  final double lon;
  final String departamento;
  final String pais;

  const MapPreviewPage({
    super.key,
    required this.nombre,
    required this.lat,
    required this.lon,
    required this.departamento,
    required this.pais,
  });

  @override
  State<MapPreviewPage> createState() => _MapPreviewPageState();
}

class _MapPreviewPageState extends State<MapPreviewPage> {
  mp.MapboxMap? map;
  mp.PointAnnotationManager? _pinManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: Text(
          widget.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          mp.MapWidget(
            styleUri: mp.MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
          ),

          // 🟩 Tarjeta con info del terreno
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${widget.departamento} • ${widget.pais}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAPA LISTO
  // ============================================================
  Future<void> _onMapCreated(mp.MapboxMap controller) async {
    map = controller;

    // Administrador de Pines
    _pinManager = await map!.annotations.createPointAnnotationManager();

    // 📌 Crear el pin (con Point correcto)
    final punto = mp.Point(
      coordinates: mp.Position(widget.lon, widget.lat),
    );

    await _pinManager!.create(
      mp.PointAnnotationOptions(
        geometry: punto,
        iconSize: 1.6,
      ),
    );

    // 🎯 AUTO ZOOM CORRECTO (sin error)
    await map!.flyTo(
      mp.CameraOptions(
        center: punto,
        zoom: 16.5,
        pitch: 45,
        bearing: 0,
      ),
      mp.MapAnimationOptions(duration: 1200),
    );
  }
}
