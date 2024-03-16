import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/add_complaint_page.dart';
import 'package:tcc_app/pages/complaint_page.dart';
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
  final Set<Polyline> _polyline = {};

  // list of locations to display polylines
  List<LatLng> latLen = [
    LatLng(-15.7593124, -47.8677623),
    LatLng(-15.7612536, -47.874618),
    LatLng(-15.7623481, -47.8743203),
    LatLng(-15.7624539, -47.8747092),
    LatLng(-15.7622397, -47.8749775),
    LatLng(-15.7627353, -47.8768845),
  ];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-15.762780851912703, -47.87026321271443),
    zoom: 17,
  );

  late StreamSubscription<List<Complaint>> _complaintsSubscription;

  @override
  void initState() {
    super.initState();
    _loadComplaints();

    //Configurar o stream para atualizações no Firestore
    _complaintsSubscription =
        _fireStoreMethods.getComplaintsStream().listen((complaints) {
      _updateMarkers(complaints);
    });

    for (int i = 0; i < latLen.length; i++) {
      _markers.add(
          // added markers
          Marker(
        markerId: MarkerId(i.toString()),
        position: latLen[i],
        infoWindow: InfoWindow(
          title: 'HOTEL',
          snippet: '5 Star Hotel',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('1'),
        points: latLen,
        color: Colors.green,
      ));
    }
  }

  String formatComplaintDetails(
      String tipoDesordem, DateTime dataOcorrido, DateTime horaOcorrido) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(dataOcorrido);
    String formattedTime = DateFormat.Hm().format(horaOcorrido);

    return '$tipoDesordem, $formattedTime $formattedDate';
  }

  String truncateDescription(String description) {
    int maxLength = 40;
    if (description.length <= maxLength) {
      return description;
    } else {
      return '${description.substring(0, maxLength)}...';
    }
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
                title: formatComplaintDetails(complaint.typeSpecification,
                    complaint.dateOfOccurrence, complaint.hourOfOccurrence),
                snippet: truncateDescription(complaint.description),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ComplaintPage(
                              complaintId: complaint.complaintId,
                            ))),
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
    // try {
    //   List<Complaint> complaints = await _fireStoreMethods.getComplaints();
    //   _updateMarkers(complaints);
    // } catch (error) {
    //   print("Erro ao carregar denúncias: $error");
    // }
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
        polylines: _polyline,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddComplaintPage())),
        label: const Icon(Icons.add),
      ),
    );
  }
}
