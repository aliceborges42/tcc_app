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
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final ComplaintMethods _complaintMethods = ComplaintMethods();
  final Set<Marker> _markers = {};
  final Set<Marker> _buttonsMarkers = {};
  final Set<Polyline> _polyline = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  // list of locations to display polylines
  List<LatLng> cooredor1 = [
    const LatLng(-15.7593124, -47.8677623),
    const LatLng(-15.7612536, -47.874618),
    const LatLng(-15.7623481, -47.8743203),
    const LatLng(-15.7624539, -47.8747092),
    const LatLng(-15.7622397, -47.8749775),
    const LatLng(-15.7627353, -47.8768845),
  ];
  List<LatLng> cooredor2 = [
    const LatLng(-15.76149, -47.867767),
    const LatLng(-15.7626567, -47.8704385),
    const LatLng(-15.7636222, -47.8715221),
    const LatLng(-15.7639113, -47.8715114),
    const LatLng(-15.7651193, -47.8734479),
    const LatLng(-15.7649077, -47.8735659),
    const LatLng(-15.7656149, -47.8761301),
  ];
  List<LatLng> cooredor3 = [
    const LatLng(-15.7631168, -47.867216),
    const LatLng(-15.7637725, -47.8682567),
    const LatLng(-15.765963, -47.8698144),
    const LatLng(-15.7678434, -47.8726856),
    const LatLng(-15.7663823, -47.8730959),
    const LatLng(-15.7669554, -47.8757406),
  ];
  List<LatLng> cooredor4 = [
    const LatLng(-15.7635645, -47.8646506),
    const LatLng(-15.7684225, -47.8683413),
    const LatLng(-15.76723, -47.8691084),
    const LatLng(-15.771251, -47.8720552),
    const LatLng(-15.7709206, -47.8721517),
    const LatLng(-15.7715478, -47.8747427),
  ];
  List<LatLng> cooredor5 = [
    const LatLng(-15.761388, -47.8676329),
    const LatLng(-15.7637009, -47.8660933),
    const LatLng(-15.7635151, -47.8644625),
    const LatLng(-15.7635512, -47.8607289),
    const LatLng(-15.7653375, -47.8589586),
  ];

  String? _statusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _complaintTypeFilter;
  List<TypeSpecification> _typeSpecifications = [];
  TypeSpecification? _selectedTypeSpecification;

  int tabletSize = 60;
  int mobileSize = 132;
  int bigtablet = 100;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-15.762780851912703, -47.87026321271443),
    zoom: 17,
  );

  @override
  void initState() {
    super.initState();
    _getTypeSpecifications();
    _loadComplaints();
    _loadButtons();

    for (int i = 0; i < cooredor1.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: const PolylineId('1'),
        points: cooredor1,
        color: Colors.green,
      ));
    }

    for (int i = 0; i < cooredor2.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: const PolylineId('2'),
        points: cooredor2,
        color: Colors.yellow,
      ));
    }

    for (int i = 0; i < cooredor3.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: const PolylineId('3'),
        points: cooredor3,
        color: Colors.blue,
      ));
    }

    for (int i = 0; i < cooredor4.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: const PolylineId('4'),
        points: cooredor4,
        color: Colors.orange,
      ));
    }

    for (int i = 0; i < cooredor5.length; i++) {
      setState(() {});
      _polyline.add(Polyline(
        polylineId: const PolylineId('5'),
        points: cooredor5,
        color: Colors.purple,
      ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCustomIcon();
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

  Future<void> _loadComplaints() async {
    try {
      List<Complaint> complaints = await _complaintMethods.getAllComplaints();

      complaints = _applyFilters(complaints);

      _updateMarkers(complaints);
    } catch (error) {
      print("Failed to load complaints: $error");
    }
  }

  Future<void> _getTypeSpecifications() async {
    try {
      List<TypeSpecification> typesSpecifications =
          await ComplaintMethods().getTypeSpecifications();
      setState(() {
        _typeSpecifications = typesSpecifications;
      });
    } catch (error) {
      print("Failed to load type specifications: $error");
      // return [];
    }
  }

  List<Complaint> _applyFilters(List<Complaint> complaints) {
    return complaints.where((complaint) {
      bool statusFilter = _statusFilter == null ||
          _statusFilter == 'Todos' ||
          complaint.status == _statusFilter;

      bool typeFilter = _complaintTypeFilter == null ||
          _complaintTypeFilter == 'Todos' ||
          complaint.complaintType.classification == _complaintTypeFilter;

      bool startDateFilter = _startDateFilter == null ||
          (complaint.date.isAfter(_startDateFilter!) ||
              complaint.date.isAtSameMomentAs(_startDateFilter!));

      bool typeSpecificationFilter = _selectedTypeSpecification == null ||
          complaint.typeSpecification.id == _selectedTypeSpecification?.id;

      bool endDateFilter = _endDateFilter == null ||
          (complaint.date.isBefore(_endDateFilter!) ||
              complaint.date.isAtSameMomentAs(_endDateFilter!));

      return statusFilter &&
          typeFilter &&
          startDateFilter &&
          endDateFilter &&
          typeSpecificationFilter;
    }).toList();
  }

  void _updateMarkers(List<Complaint> complaints) {
    setState(() {
      _markers.clear();
      for (Complaint complaint in complaints) {
        _markers.add(
          Marker(
            markerId: MarkerId('complaint_${complaint.id.toString()}'),
            position: LatLng(
              complaint.latitude,
              complaint.longitude,
            ),
            infoWindow: InfoWindow(
              title: '${complaint.typeSpecification.specification}',
              snippet: '${complaint.description}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintPage(
                    complaintId: complaint.id.toString(),
                  ),
                ),
              ),
            ),
            zIndex: 1,
          ),
        );
      }
    });
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que o BottomSheet ocupe o tamanho completo da tela
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Filtros',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),

                    DropdownButtonFormField<String>(
                      value: _statusFilter,
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value;
                        });
                      },
                      items: ['Todos', 'Resolvido', 'Não Resolvido']
                          .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: 'Status'),
                    ),
                    // SizedBox(height: 6.0),
                    DropdownButtonFormField<String>(
                      value: _complaintTypeFilter,
                      onChanged: (value) {
                        setState(() {
                          _complaintTypeFilter = value;
                        });
                      },
                      items: ['Todos', 'Episódio', 'Desordem']
                          .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                          .toList(),
                      decoration:
                          InputDecoration(labelText: 'Tipo de Denúncia'),
                    ),
                    // SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _selectedTypeSpecification?.specification,
                      onChanged: (value) {
                        final selectedType = _typeSpecifications.firstWhere(
                          (type) => type.specification == value,
                          orElse: () => _typeSpecifications.first,
                        );
                        setState(() {
                          _selectedTypeSpecification = selectedType;
                        });
                      },
                      items: _typeSpecifications
                          .map((label) => DropdownMenuItem(
                                child: Text(label.specification),
                                value: label.specification,
                              ))
                          .toList(),
                      decoration: InputDecoration(
                          labelText: 'Especificação da Denúncia'),
                    ),
                    SizedBox(height: 8.0),
                    Text('Data de Início'),
                    SizedBox(height: 4.0),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDateFilter = picked;
                          });
                        }
                      },
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple)),
                      child: Text(
                        _startDateFilter != null
                            ? DateFormat('dd/MM/yyyy').format(_startDateFilter!)
                            : 'Selecionar Data',
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text('Data de Fim'),
                    SizedBox(height: 4.0),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDateFilter = picked;
                          });
                        }
                      },
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple)),
                      child: Text(
                        _endDateFilter != null
                            ? DateFormat('dd/MM/yyyy').format(_endDateFilter!)
                            : 'Selecionar Data',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // _applyFilters();
                        _loadComplaints();
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                      child: Text('Aplicar Filtros'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<BitmapDescriptor> createCustomIcon(String imagePath, int size) async {
    // Carregar a imagem como ByteData
    ByteData imageData = await rootBundle.load(imagePath);
    Uint8List bytes = imageData.buffer.asUint8List();

    // Decodificar a imagem
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image image = frameInfo.image;

    // Redimensionar a imagem para 64x64 pixels
    ui.Image resizedImage = await _resizeImage(image, size, size);

    // Converter a imagem para bytes
    ByteData? byteData =
        await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      Uint8List resizedBytes = byteData.buffer.asUint8List();

      // Retornar o BitmapDescriptor
      return BitmapDescriptor.fromBytes(resizedBytes);
    } else {
      throw Exception('Falha ao converter a imagem para bytes');
    }
  }

  Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    // Criar uma nova instância de PictureRecorder
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    // Redimensionar a imagem no canvas
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    // Concluir a gravação
    ui.Picture picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  Future<void> _loadCustomIcon() async {
    final Size screenSize = MediaQuery.of(context).size;
    final double deviceWidth = screenSize.width;
    // final double deviceHeight = screenSize.height;
    print('Tablet size ');
    print(deviceWidth);
    final int deviceSize;
    if (deviceWidth >= 800) {
      deviceSize = bigtablet;
    } else if (deviceWidth >= 600) {
      deviceSize = tabletSize;
    } else {
      deviceSize = mobileSize;
    }

    // Carregar o ícone personalizado com o tamanho do dispositivo
    BitmapDescriptor customIcon = await createCustomIcon(
        "assets/images/emergency-button.png", deviceSize);
    setState(() {
      markerIcon = customIcon;
    });
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
              icon: markerIcon,
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
    super.dispose();
  }

  Future<void> _loadButtons() async {
    try {
      List<SecurityButton> securityButtons =
          await SecurityButtonMethods().getAllSecurityButtons();

      _updateButtonsMarkers(securityButtons);
    } catch (error) {
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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa da UnB'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: _openFilterModal,
              tooltip: 'Filtrar denúncias',
            ),
            Container(
              padding: const EdgeInsets.all(6),
              color: Colors.red[100],
              child: IconButton(
                tooltip: 'Ligar para a segurança',
                icon: const Icon(Icons.phone),
                color: Colors.red[700],
                onPressed: () => _callSecurity(),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _getAllMarkers(),
          polylines: _polyline,
          myLocationEnabled: false,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddComplaintPage()),
          ),
          backgroundColor: Colors.deepPurple[600],
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          tooltip: 'Criar nova denúncia',
        ));
  }

  void _callSecurity() async {
    const String phoneNumber = '6131076222';
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chamada de Emergência'),
          content: const Text(
              'Tem certeza que deseja ligar para a segurança dda UnB?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green[600],
                elevation: 0,
              ),
              child: const Text('LIGAR'),
              onPressed: () async {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Não foi possível fazer a ligação.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
