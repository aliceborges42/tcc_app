// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:tcc_app/models/complaint_model.dart';
// import 'package:tcc_app/pages/add_complaint_page.dart';
// import 'package:tcc_app/pages/complaint_page.dart';
// import 'package:tcc_app/resources/complaint_methods.dart';
// import 'dart:async';

// class MapSample extends StatefulWidget {
//   const MapSample({Key? key}) : super(key: key);

//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polyline = {};

//   late StreamSubscription<List<Complaint>> _complaintsSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _loadComplaints();

//     _complaintsSubscription =
//         ComplaintMethods().getAllComplaintsStream().listen((complaints) {
//       _updateMarkers(complaints);
//     });
//   }

//   String formatComplaintDetails(
//       String tipoDesordem, DateTime dataOcorrido, DateTime horaOcorrido) {
//     String formattedDate = DateFormat('dd/MM/yyyy').format(dataOcorrido);
//     String formattedTime = DateFormat.Hm().format(horaOcorrido);

//     return '$tipoDesordem, $formattedTime $formattedDate';
//   }

//   String truncateDescription(String description) {
//     int maxLength = 40;
//     if (description.length <= maxLength) {
//       return description;
//     } else {
//       return '${description.substring(0, maxLength)}...';
//     }
//   }

//   void _updateMarkers(List<Complaint> complaints) {
//     print('\n\nupateMarkers');
//     setState(() {
//       _markers.clear();
//       for (Complaint complaint in complaints) {
//         print(complaint);
//         if (complaint.latitude != null && complaint.longitude != null) {
//           _markers.add(
//             Marker(
//               markerId: MarkerId(complaint.id.toString()),
//               position: LatLng(
//                 complaint.latitude,
//                 complaint.longitude,
//               ),
//               infoWindow: InfoWindow(
//                 title: formatComplaintDetails(
//                   complaint.typeSpecification.specification,
//                   complaint.date,
//                   complaint.hour,
//                 ),
//                 snippet: truncateDescription(complaint.description),
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ComplaintPage(
//                       complaintId: complaint.id.toString(),
//                     ),
//                   ),
//                 ),
//               ),
//               zIndex: 1,
//             ),
//           );
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _complaintsSubscription.cancel();
//     super.dispose();
//   }

//   Future<void> _loadComplaints() async {
//     try {
//       List<Complaint> complaints = await ComplaintMethods().getAllComplaints();
//       _updateMarkers(complaints);
//     } catch (error) {
//       print("Erro ao carregar denúncias: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: const LatLng(-15.762780851912703, -47.87026321271443),
//           zoom: 17,
//         ),
//         onMapCreated: (GoogleMapController controller) {},
//         markers: _markers,
//         polylines: _polyline,
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AddComplaintPage()),
//         ),
//         label: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/add_complaint_page.dart';
import 'package:tcc_app/pages/complaint_page.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
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

    // Configurar o stream para atualizações no Firestore
    _complaintsSubscription =
        _complaintMethods.getAllComplaintsStream().listen((complaints) {
      _updateMarkers(complaints);
    });

    // print('\n\n\n COMPLAINT STREAM:\n');
    // print(_complaintsSubscription);
    // print('\n-------------------------------\n\n');

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
    if (complaints.isNotEmpty) {
      setState(() {
        _markers.clear();
        for (Complaint complaint in complaints) {
          print('\n\n\n\n COMPLAINT\n');
          print(complaint.description);
          print('\n---------------------\n\n\n');
          _markers.add(
            Marker(
              markerId: MarkerId(complaint.id.toString()),
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

  @override
  void dispose() {
    _complaintsSubscription.cancel();
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

  @override
  Widget build(BuildContext context) {
    print('MERKERS ');
    print(_markers.length);
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
