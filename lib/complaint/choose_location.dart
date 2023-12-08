import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseLocationMap extends StatefulWidget {
  const ChooseLocationMap({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChooseLocationMapState createState() => _ChooseLocationMapState();
}

class _ChooseLocationMapState extends State<ChooseLocationMap> {
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher Localização'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(
              -15.762780851912703, -47.87026321271443), // Coordenadas iniciais
          zoom: 17,
        ),
        markers: _markers,
        onTap: (LatLng latLng) {
          setState(() {
            _markers.clear();
            _markers.add(Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
              draggable: true,
              onDragEnd: (dragEndPosition) {
                setState(() {
                  _selectedLocation = dragEndPosition;
                });
              },
            ));
            _selectedLocation = latLng;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Retornar a localização selecionada quando o botão for pressionado
          Navigator.pop(context, _selectedLocation);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
