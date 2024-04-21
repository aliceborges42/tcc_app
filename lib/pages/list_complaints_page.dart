import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/components/datepicker.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/complaint_page.dart';
import 'package:tcc_app/resources/complaint_methods.dart';

class ComplaintListPage extends StatefulWidget {
  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  late Future<List<Complaint>> _complaintsFuture;
  List<Complaint> _complaints = [];
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _selectedStatusFilter;
  String? _selectedComplaintTypeFilter;
  TypeSpecification? _selectedTypeSpecification;
  List<TypeSpecification> _typeSpecifications = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    _complaintsFuture = _loadComplaints();
    _typeSpecifications = await _getTypeSpecifications();
  }

  Future<List<TypeSpecification>> _getTypeSpecifications() async {
    try {
      return await ComplaintMethods().getTypeSpecifications();
    } catch (error) {
      print("Failed to load type specifications: $error");
      return [];
    }
  }

  void _applyFilters() {
    setState(() {
      _complaintsFuture = _loadComplaintsFiltered();
    });
  }

  Future<List<Complaint>> _loadComplaintsFiltered() async {
    List<Complaint> complaints = await _loadComplaints();

    complaints = complaints.where((complaint) {
      bool statusFilter = _selectedStatusFilter == null ||
          complaint.status == _selectedStatusFilter;

      bool typeFilter = _selectedComplaintTypeFilter == null ||
          complaint.complaintType.classification ==
              _selectedComplaintTypeFilter;

      bool typeSpecificationFilter = _selectedTypeSpecification == null ||
          complaint.typeSpecification.id == _selectedTypeSpecification?.id;

      bool startDateFilter = _startDateFilter == null ||
          (complaint.date.isAfter(_startDateFilter!) ||
              complaint.date.isAtSameMomentAs(_startDateFilter!));

      bool endDateFilter = _endDateFilter == null ||
          (complaint.date.isBefore(_endDateFilter!) ||
              complaint.date.isAtSameMomentAs(_endDateFilter!));

      return statusFilter &&
          typeFilter &&
          typeSpecificationFilter &&
          startDateFilter &&
          endDateFilter;
    }).toList();

    return complaints;
  }

  Future<List<Complaint>> _loadComplaints() async {
    try {
      return await ComplaintMethods().getAllComplaints();
    } catch (error) {
      print("Failed to load complaints: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Denúncias'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar denúncia...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _complaintsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        "Erro ao carregar as denúncias: ${snapshot.error}"),
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
                            minVerticalPadding: 8.0,
                            title:
                                Text(complaint.typeSpecification.specification),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(complaint.description),
                                SizedBox(height: 4),
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
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              label: Text(complaint.status!),
                              labelStyle: TextStyle(
                                  color: complaint.status == 'Resolvido'
                                      ? Colors.green[900]
                                      : Colors.red[900]),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComplaintPage(
                                    complaintId: complaint.id.toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(
                            height: 0,
                            color: Colors.grey[600],
                          ),
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
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Filtros',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedStatusFilter,
                  items: ['Todos', 'Resolvido', 'Não Resolvido']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Status'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatusFilter = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedComplaintTypeFilter,
                  items: ['Todos', 'Episódio', 'Desordem']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedComplaintTypeFilter = newValue;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Tipo de Denúncia'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedTypeSpecification?.specification,
                  items: _typeSpecifications
                      .map((label) => DropdownMenuItem(
                            child: Text(label.specification),
                            value: label.specification,
                          ))
                      .toList(),
                  decoration:
                      InputDecoration(labelText: 'Especificação da Denúncia'),
                  onChanged: (value) {
                    final selectedType = _typeSpecifications.firstWhere(
                      (type) => type.specification == value,
                      orElse: () => _typeSpecifications.first,
                    );
                    setState(() {
                      _selectedTypeSpecification = selectedType;
                    });
                  },
                ),
                SizedBox(height: 8.0),
                CustomDatePicker(
                  initialDate: _startDateFilter,
                  labelText: 'Data de Início',
                  onChanged: (DateTime? newValue) {
                    setState(() {
                      _startDateFilter = newValue;
                    });
                  },
                ),
                CustomDatePicker(
                  initialDate: _endDateFilter,
                  labelText: 'Data de Fim',
                  onChanged: (DateTime? newValue) {
                    setState(() {
                      _endDateFilter = newValue;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.deepPurple)),
                  child: Text('Aplicar Filtros'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _complaintsFuture = _searchComplaints(query);
      } else {
        _complaintsFuture = _loadComplaints();
      }
    });
  }

  Future<List<Complaint>> _searchComplaints(String query) async {
    try {
      return await ComplaintMethods().searchComplaints(query);
    } catch (error) {
      print("Failed to search complaints: $error");
      return [];
    }
  }
}
