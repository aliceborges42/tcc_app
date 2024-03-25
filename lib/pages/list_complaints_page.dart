import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:tcc_app/pages/complaint_page.dart';

class ComplaintListPage extends StatefulWidget {
  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  late Future<List<Complaint>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _loadComplaints();
  }

  Future<List<Complaint>> _loadComplaints() async {
    try {
      List<Complaint> complaints = await ComplaintMethods().getAllComplaints();
      return complaints;
    } catch (error) {
      print("Failed to load complaints: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Denúncias'),
      ),
      body: FutureBuilder(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao carregar as denúncias: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            List<Complaint> complaints = snapshot.data as List<Complaint>;
            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                Complaint complaint = complaints[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(complaint.typeSpecification.specification),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(complaint.description),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy').format(complaint.date)}',
                          ),
                          Text(
                            'Hora: ${DateFormat('HH:mm').format(complaint.hour)}',
                          ),
                        ],
                      ),
                      trailing: Chip(
                        backgroundColor: complaint.status == 'Resolvido'
                            ? Colors.green[300]
                            : Colors.red[300],
                        label: Text(complaint.status!),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintPage(
                                complaintId: complaint.id.toString()),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 0,
                      color: Colors.grey[600],
                    ), // Adiciona um Divider após o ListTile
                  ],
                );
              },
            );
          } else {
            return Center(
              child: Text("Nenhuma denúncia encontrada."),
            );
          }
        },
      ),
    );
  }
}
