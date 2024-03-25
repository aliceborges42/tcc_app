import 'package:flutter/material.dart';
import 'package:tcc_app/components/carousel.dart';
import 'package:tcc_app/resources/firestore_methods.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:geocode/geocode.dart';
import 'package:tcc_app/resources/map_methods.dart';
import 'package:tcc_app/resources/format_methods.dart';
import 'package:tcc_app/resources/complaint_methods.dart';

class ComplaintPage extends StatefulWidget {
  final String complaintId;

  const ComplaintPage({Key? key, required this.complaintId}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  late Future<Complaint> _complaintFuture;
  String _locationText = "Loading data...";
  String _dateText = "Loading data...";

  @override
  void initState() {
    super.initState();
    _complaintFuture = _loadComplaintDetails();
  }

  Future<Complaint> _loadComplaintDetails() async {
    try {
      Complaint? complaint =
          await ComplaintMethods().getComplaintById(widget.complaintId);
      _loadLocationDetails(complaint.latitude, complaint.longitude);
      _loadDateDetails(complaint.date);
      return complaint;
    } catch (error) {
      print("Erro ao carregar detalhes da denúncia: $error");
      throw error;
    }
  }

  Future<void> _loadLocationDetails(double lat, double lon) async {
    try {
      String address = await getAddressByLatLon(lat, lon);
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _locationText = address;
        });
      }
    } catch (error) {
      print("Erro ao carregar endereço: $error");
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _locationText = "Erro ao carregar endereço.";
        });
      }
    }
  }

  Future<void> _loadDateDetails(DateTime date) async {
    try {
      String dateOfOccurrence = await formatDate(date);
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _dateText = dateOfOccurrence;
        });
      }
    } catch (error) {
      print("Erro ao carregar endereço: $error");
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _dateText = "Erro ao carregar endereço.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Denúncia'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _complaintFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Erro ao carregar detalhes da denúncia: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              Complaint complaint = snapshot.data as Complaint;

              // Carrega os detalhes de localização (endereço)
              // _loadLocationDetails(complaint.latitude, complaint.longitude);
              // _loadDateDetails(complaint.date);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Carousel(
                      images: complaint.images!,
                      height: MediaQuery.of(context).size.height * 0.25,
                      viewportFraction: 1.0,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (BuildContext context) {
                          return Carousel(
                            images: complaint.images!,
                            height: MediaQuery.of(context).size.height * 0.8,
                            viewportFraction: 0.8,
                          );
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.typeSpecification.specification,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w400),
                        ),
                        const Text(
                          'Descrição:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(complaint.description),
                        const SizedBox(height: 16),
                        const Text(
                          'Endereço:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(_locationText),
                        const SizedBox(height: 16),
                        const Text(
                          'Data do Ocorrido:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(_dateText),
                        const Text(
                          'Hora do Ocorrido:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(formatHour(complaint.hour)),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child:
                    Text("Erro desconhecido ao carregar detalhes da denúncia."),
              );
            }
          },
        ),
      ),
    );
  }
}
