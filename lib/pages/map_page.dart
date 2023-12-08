import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/add_complaint_page.dart';
import 'dart:async';

import 'package:tcc_app/pages/home_page.dart';
import 'package:tcc_app/resources/firestore_methods.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final FireStoreMethods _fireStoreMethods = FireStoreMethods();
  final Set<Marker> _markers = {};
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-15.762780851912703, -47.87026321271443),
    zoom: 17,
  );

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      List<Complaint> complaints = await _fireStoreMethods.getComplaints();
      // print('COMPLAINT:');
      // print(complaints.length);
      setState(() {
        _markers.clear();
        for (Complaint complaint in complaints) {
          if (complaint.local != null) {
            _markers.add(
              Marker(
                markerId: MarkerId(complaint.complaintId),
                position: LatLng(
                  complaint.local!.latitude,
                  complaint.local!.longitude,
                ),
                // Adicione mais detalhes do marcador conforme necessário
                infoWindow: InfoWindow(title: complaint.description),
                zIndex: 1,
              ),
            );
          }
        }
      });
    } catch (error) {
      print("Erro ao carregar denúncias: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddComplaintPage())),
        label: const Icon(Icons.add),
      ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
