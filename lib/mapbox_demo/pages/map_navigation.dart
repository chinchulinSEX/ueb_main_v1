// file: lib/map_navigation_page.dart
// Página de navegación profesional – Suelo & Agua
// Compatible con HomePage y AR Navigation

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

import 'ar_navigation_3d.dart';

// 🎨 Colores institucionales
const azulAgua = Color(0xFF1565C0);
const celesteGota = Color(0xFF29B6F6);
const verdeHoja = Color(0xFF4CAF50);

class MapNavigationPage extends StatefulWidget {
  final double destLat;
  final double destLon;
  final String destName;

  const MapNavigationPage({
    super.key,
    required this.destLat,
    required this.destLon,
    required this.destName,
  });

  @override
  State<MapNavigationPage> createState() => _MapNavigationPageState();
}

class _MapNavigationPageState extends State<MapNavigationPage> {
  mp.MapboxMap? map;
  mp.PolylineAnnotationManager? _routeManager;
  mp.PolylineAnnotation? _route;

  gl.Position? _currentPos;
  StreamSubscription<gl.Position>? _posStream;

  bool _loading = true;
  bool _isDriving = true;

  String _tiempo = "";
  String _distancia = "";

  List<String> _instrucciones = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posStream?.cancel();
    super.dispose();
  }

  // ============================================================
  // UI PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            styleUri: mp.MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
          ),

          // 📌 Tarjeta de instrucciones
          if (_instrucciones.isNotEmpty)
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [azulAgua, celesteGota],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: azulAgua.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _instrucciones.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tiempo: $_tiempo   •   Distancia: $_distancia",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ❌ Botón Cerrar
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: azulAgua,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 🚗/🚶 Cambiar modo
          Positioned(
            top: 120,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: verdeHoja,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isDriving ? Icons.directions_car : Icons.directions_walk,
                color: Colors.white,
              ),
              onPressed: () async {
                setState(() {
                  _isDriving = !_isDriving;
                  _loading = true;
                });
                if (_currentPos != null) await _dibujarRuta();
                setState(() => _loading = false);
              },
            ),
          ),

          // 🟦 Modo AR
          Positioned(
            bottom: 40,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulAgua,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              icon: const Icon(Icons.view_in_ar, color: Colors.white, size: 28),
              label: const Text(
                "Modo AR",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: _abrirModoAr,
            ),
          ),

          // Loader
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                color: azulAgua,
                strokeWidth: 4,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // UBICACIÓN
  // ============================================================
  Future<void> _initLocation() async {
    const settings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.best,
      distanceFilter: 3,
    );

    _posStream = gl.Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      _currentPos = pos;
    });
  }

  // ============================================================
  // MAPA LISTO
  // ============================================================
  Future<void> _onMapCreated(mp.MapboxMap controller) async {
    map = controller;

    await map!.location.updateSettings(
      mp.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    _routeManager = await map!.annotations.createPolylineAnnotationManager();

    // 📍 Obtener tu ubicación
    _currentPos = await gl.Geolocator.getCurrentPosition();

    // 🛣 Dibujar ruta desde tu ubicación → destino
    await _dibujarRuta();

    // ⭐ AUTO ZOOM / AUTO FOCUS HACIA EL DESTINO
    await map!.flyTo(
      mp.CameraOptions(
        center: mp.Point(
          coordinates: mp.Position(
            widget.destLon,
            widget.destLat,
          ),
        ),
        zoom: 15.5,
        pitch: 45,
        bearing: 0,
      ),
      mp.MapAnimationOptions(duration: 1500),
    );

    setState(() => _loading = false);
  }

  // ============================================================
  // DIBUJAR RUTA
  // ============================================================
  Future<void> _dibujarRuta() async {
    if (_currentPos == null) return;

    final start = "${_currentPos!.longitude},${_currentPos!.latitude}";
    final end = "${widget.destLon},${widget.destLat}";
    final profile = _isDriving ? "driving" : "walking";
    final token = dotenv.env["MAPBOX_ACCESS_TOKEN"];

    final url = Uri.parse(
      "https://api.mapbox.com/directions/v5/mapbox/$profile/$start;$end"
      "?geometries=geojson&overview=full&steps=true&access_token=$token",
    );

    final res = await http.get(url);
    final json = jsonDecode(res.body);
    final route = json["routes"][0];

    final coords = route["geometry"]["coordinates"];
    final puntos = coords
        .map<mp.Position>((e) => mp.Position(e[0].toDouble(), e[1].toDouble()))
        .toList();

    await _routeManager?.deleteAll();
    _route = await _routeManager!.create(
      mp.PolylineAnnotationOptions(
        geometry: mp.LineString(coordinates: puntos),
        lineColor: 0xFF1565C0, // Azul corporativo
        lineWidth: 6,
      ),
    );

    _distancia = "${(route["distance"] / 1000).toStringAsFixed(1)} km";
    _tiempo = "${(route["duration"] / 60).toStringAsFixed(0)} min";

    final pasos = route["legs"][0]["steps"];
    _instrucciones = pasos.map<String>((s) {
      final name = s['name'] ?? "camino";
      final fix = s['maneuver']['modifier'] ?? "seguir";
      if (fix == "left") return "⬅️ Girar a la izquierda por $name";
      if (fix == "right") return "➡️ Girar a la derecha por $name";
      return "⬆️ Seguir recto por $name";
    }).toList();

    setState(() {});
  }

  // ============================================================
  // MODO AR
  // ============================================================
  void _abrirModoAr() {
    if (_route == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArNavigation3D(
          targetLat: widget.destLat,
          targetLon: widget.destLon,
          targetName: widget.destName,
          routeWaypoints: _route!.geometry.coordinates
              .map((p) => {'lat': p.lat, 'lon': p.lng})
              .toList(),
        ),
      ),
    );
  }
}
