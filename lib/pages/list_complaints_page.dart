import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/complaint_page.dart';
import 'package:tcc_app/resources/complaint_methods.dart';

class ComplaintListPage extends StatefulWidget {
  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  late Future<List<Complaint>> _complaintsFuture;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  TypeSpecification? _selectedTypeSpecification;
  List<TypeSpecification> _typeSpecifications = [];
  TextEditingController _searchController = TextEditingController();
  String? _statusFilter;
  String? _complaintTypeFilter;

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
                        _loadComplaintsFiltered();
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadComplaintsFiltered() async {
    setState(() {
      _complaintsFuture = _loadComplaints();
    });
  }

  Future<List<Complaint>> _loadComplaints() async {
    try {
      List<Complaint> complaints = await ComplaintMethods().getAllComplaints();

      return _applyFilters(complaints);
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
              _openFilterModal();
            },
            tooltip: 'Filtrar denúncias',
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar denúncia...',
                prefixIcon: Icon(
                  Icons.search,
                  semanticLabel: 'pesquisar denúncia',
                ),
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
                                side: const BorderSide(
                                    color: Colors.transparent)),
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
                            color: Colors.grey[500],
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
