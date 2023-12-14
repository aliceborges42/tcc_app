import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/add_complaint_page.dart';
import 'dart:async';
import 'package:tcc_app/resources/firestore_methods.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

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

  late StreamSubscription<List<Complaint>> _complaintsSubscription;

  @override
  void initState() {
    super.initState();
    _loadComplaints();

    // Configurar o stream para atualizações no Firestore
    _complaintsSubscription =
        _fireStoreMethods.getComplaintsStream().listen((complaints) {
      _updateMarkers(complaints);
    });
  }

  void _updateMarkers(List<Complaint> complaints) {
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
              infoWindow: InfoWindow(
                title: complaint.description,
                snippet: complaint.dateOfOccurrence.toString(),
              ),
              zIndex: 1,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _complaintsSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    try {
      List<Complaint> complaints = await _fireStoreMethods.getComplaints();
      _updateMarkers(complaints);
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
}
