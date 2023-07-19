import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapEditor extends StatefulWidget {
  const MapEditor({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  final MapController _mapController = MapController();
  LatLng? _selectedPoint;
  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPoint = widget.initialLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinpoint your location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center:
                  widget.initialLocation ?? const LatLng(3.049364, 102.12928),
              zoom: 12.5,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedPoint = position.center;
                  });
                }
              },
            ),
            nonRotatedChildren: [
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'iium-buditimebank',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    builder: (_) => IconButton(
                      icon: const Icon(Icons.location_on),
                      color: Colors.blueAccent,
                      iconSize: 45,
                      onPressed: () {},
                    ),
                    point: _selectedPoint ?? const LatLng(3.049364, 102.12928),
                  ),
                ],
              )
            ],
          ),
          Positioned(
            bottom: 10,
            child: Card(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${_selectedPoint?.latitude.toStringAsFixed(4)}, ${_selectedPoint?.longitude.toStringAsFixed(4)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedPoint);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
