import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/models/security_button_model.dart';
import 'package:tcc_app/pages/add_complaint_page.dart';
import 'package:tcc_app/pages/complaint_page.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:tcc_app/resources/security_buttons_methods.dart';
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
  // final FireStoreMethods _fireStoreMethods = FireStoreMethods();
  final ComplaintMethods _complaintMethods = ComplaintMethods();
  final Set<Marker> _markers = {};
  final Set<Marker> _buttonsMarkers = {};
  final Set<Polyline> _polyline = {};

  // list of locations to display polylines
  List<LatLng> cooredor1 = [
    LatLng(-15.7593124, -47.8677623),
    LatLng(-15.7612536, -47.874618),
    LatLng(-15.7623481, -47.8743203),
    LatLng(-15.7624539, -47.8747092),
    LatLng(-15.7622397, -47.8749775),
    LatLng(-15.7627353, -47.8768845),
  ];
  List<LatLng> cooredor2 = [
    LatLng(-15.76149, -47.867767),
    LatLng(-15.7626567, -47.8704385),
    LatLng(-15.7636222, -47.8715221),
    LatLng(-15.7639113, -47.8715114),
    LatLng(-15.7651193, -47.8734479),
    LatLng(-15.7649077, -47.8735659),
    LatLng(-15.7656149, -47.8761301),
  ];
  List<LatLng> cooredor3 = [
    LatLng(-15.7631168, -47.867216),
    LatLng(-15.7637725, -47.8682567),
    LatLng(-15.765963, -47.8698144),
    LatLng(-15.7678434, -47.8726856),
    LatLng(-15.7663823, -47.8730959),
    LatLng(-15.7669554, -47.8757406),
  ];
  List<LatLng> cooredor4 = [
    LatLng(-15.7635645, -47.8646506),
    LatLng(-15.7684225, -47.8683413),
    LatLng(-15.76723, -47.8691084),
    LatLng(-15.771251, -47.8720552),
    LatLng(-15.7709206, -47.8721517),
    LatLng(-15.7715478, -47.8747427),
  ];
  List<LatLng> cooredor5 = [
    LatLng(-15.761388, -47.8676329),
    LatLng(-15.7637009, -47.8660933),
    LatLng(-15.7635151, -47.8644625),
    LatLng(-15.7635512, -47.8607289),
    LatLng(-15.7653375, -47.8589586),
  ];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-15.762780851912703, -47.87026321271443),
    zoom: 17,
  );

  // late StreamSubscription<List<Complaint>> _complaintsSubscription;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
    _loadButtons();

    // Configurar o stream para atualizações no Firestore
    // _complaintsSubscription =
    //     _complaintMethods.getAllComplaintsStream().listen((complaints) {
    //   _updateMarkers(complaints);
    // });

    for (int i = 0; i < cooredor1.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('1'),
        points: cooredor1,
        color: Colors.green,
      ));
    }

    for (int i = 0; i < cooredor2.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('2'),
        points: cooredor2,
        color: Colors.yellow,
      ));
    }

    for (int i = 0; i < cooredor3.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('3'),
        points: cooredor3,
        color: Colors.blue,
      ));
    }

    for (int i = 0; i < cooredor4.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('4'),
        points: cooredor4,
        color: Colors.orange,
      ));
    }

    for (int i = 0; i < cooredor5.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('5'),
        points: cooredor5,
        color: Colors.purple,
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
    if (complaints.isNotEmpty) {
      setState(() {
        _markers.clear();
        for (Complaint complaint in complaints) {
          _markers.add(
            Marker(
              markerId: MarkerId(
                  'complaint_${complaint.id.toString()}'), // Adicionando prefixo 'complaint_'
              position: LatLng(
                complaint.latitude,
                complaint.longitude,
              ),
              infoWindow: InfoWindow(
                title: formatComplaintDetails(
                    complaint.typeSpecification.specification,
                    complaint.date,
                    complaint.hour),
                snippet: truncateDescription(complaint.description),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ComplaintPage(
                              complaintId: complaint.id.toString(),
                            ))),
              ),
              zIndex: 1,
            ),
          );
        }
      });
    }
  }

  void _updateButtonsMarkers(List<SecurityButton> securityButtons) {
    if (securityButtons.isNotEmpty) {
      setState(() {
        _buttonsMarkers.clear();
        for (SecurityButton securityButton in securityButtons) {
          _buttonsMarkers.add(
            Marker(
              markerId: MarkerId(
                  'button_${securityButton.id.toString()}'), // Adicionando prefixo 'button_'
              position: LatLng(
                securityButton.latitude,
                securityButton.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
              infoWindow: InfoWindow(
                title: 'Botão de Segurança',
                snippet: securityButton.name,
              ),
              zIndex: 1,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // _complaintsSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    try {
      List<Complaint> complaints = await _complaintMethods.getAllComplaints();

      print('\n\n\nCOMPLAINTSlenght\n');
      print(complaints.length);

      _updateMarkers(complaints);
    } catch (error) {
      List<Complaint> complaints = [];
      // _updateMarkers(complaints);
      print("Erro ao carregar denúncias: $error");
    }
  }

  Future<void> _loadButtons() async {
    try {
      List<SecurityButton> securityButtons =
          await SecurityButtonMethods().getAllSecurityButtons();

      print('\n\n\nCOMPLAINTSlenght\n');
      print(securityButtons.length);

      _updateButtonsMarkers(securityButtons);
    } catch (error) {
      List<SecurityButton> securityButtons = [];
      // _updateMarkers(complaints);
      print("Erro ao carregar botões de segurança: $error");
    }
  }

  Set<Marker> _getAllMarkers() {
    Set<Marker> allMarkers = Set<Marker>.from(_markers);
    allMarkers.addAll(_buttonsMarkers);
    return allMarkers;
  }

  @override
  Widget build(BuildContext context) {
    // print('MERKERS ');
    // print(_markers.length);
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _getAllMarkers(),
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
