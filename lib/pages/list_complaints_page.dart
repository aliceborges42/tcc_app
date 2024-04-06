import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/components/datepicker.dart';
import 'package:tcc_app/components/dropdown.dart';
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

      bool dateFilter = _startDateFilter == null ||
          _endDateFilter == null ||
          ((complaint.date.isAfter(_startDateFilter!) ||
                  complaint.date.isAtSameMomentAs(_startDateFilter!)) &&
              (complaint.date.isBefore(_endDateFilter!) ||
                  complaint.date.isAtSameMomentAs(_endDateFilter!)));

      return statusFilter &&
          typeFilter &&
          typeSpecificationFilter &&
          dateFilter;
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
                            title:
                                Text(complaint.typeSpecification.specification),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                title: Text('Filtrar por Status'),
                subtitle: CustomDropdown(
                  value: _selectedStatusFilter,
                  items: ['Todos', 'Resolvido', 'Não Resolvido'],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatusFilter = newValue;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Filtrar por Tipo de Denúncia'),
                subtitle: CustomDropdown(
                  value: _selectedComplaintTypeFilter,
                  items: ['Todos', 'Episódio', 'Desordem'],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedComplaintTypeFilter = newValue;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Filtrar por Tipo de Especificação'),
                subtitle: CustomDropdown(
                  value: _selectedTypeSpecification?.specification,
                  items: _typeSpecifications
                      .map((type) => type.specification)
                      .toList(),
                  onChanged: (String? newValue) {
                    final selectedType = _typeSpecifications.firstWhere(
                      (type) => type.specification == newValue,
                      orElse: () => _typeSpecifications.first,
                    );
                    setState(() {
                      _selectedTypeSpecification = selectedType;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Filtrar por Período de Data'),
                subtitle: Column(
                  children: [
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
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: Text('Aplicar Filtros'),
              ),
            ],
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
