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
  List<Complaint> _complaints = [];
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _selectedStatusFilter;
  String? _selectedComplantTypeFilter;
  TypeSpecification? _selectedTypeSpecification; // Adicione este campo
  List<TypeSpecification> _typeSpecifications = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Carregue as listas de reclamações e especificações de tipo
  }

  // Método para carregar os dados iniciais
  void _loadInitialData() async {
    _complaintsFuture = _loadComplaints();
    _typeSpecifications = await _getTypeSpecifications();
  }

  Future<List<TypeSpecification>> _getTypeSpecifications() async {
    try {
      return await ComplaintMethods().getTypeSpecifications();
    } catch (error) {
      print("Failed to load type specifications: $error");
      return []; // Retorna uma lista vazia em caso de erro
    }
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FilterChip(
                label: Text("Todos"),
                selected: _selectedStatusFilter == null &&
                    _startDateFilter == null &&
                    _endDateFilter == null,
                onSelected: (_) {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      _selectedStatusFilter = null;
                      _startDateFilter = null;
                      _endDateFilter = null;
                      _selectedTypeSpecification = null;
                      _complaintsFuture = _loadComplaints();
                    });
                  }
                },
              ),
              FilterChip(
                label: Text("Resolvidos"),
                selected: _selectedStatusFilter == "Resolvido",
                onSelected: (_) {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      _selectedStatusFilter = "Resolvido";
                      _complaintsFuture = _applyFilters();
                    });
                  }
                },
              ),
              FilterChip(
                label: Text("Não Resolvidos"),
                selected: _selectedStatusFilter == "Não Resolvido",
                onSelected: (_) {
                  // Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      _selectedStatusFilter = "Não Resolvido";
                      _complaintsFuture = _applyFilters();
                    });
                  }
                },
              ),
              FilterChip(
                label: Text("Episódios"),
                selected: _selectedComplantTypeFilter == "Episódio",
                onSelected: (_) {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      _selectedComplantTypeFilter = "Episódio";
                      _complaintsFuture = _applyFilters();
                    });
                  }
                },
              ),
              FilterChip(
                label: Text("Desordens"),
                selected: _selectedComplantTypeFilter == "Desordem",
                onSelected: (_) {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      _selectedComplantTypeFilter = "Desordem";
                      _complaintsFuture = _applyFilters();
                    });
                  }
                },
              ),
              DropdownButton<TypeSpecification>(
                value: _selectedTypeSpecification,
                onChanged: (TypeSpecification? newValue) {
                  setState(() {
                    _selectedTypeSpecification = newValue;
                    _complaintsFuture = _applyFilters();
                  });
                },
                items: _typeSpecifications.map((TypeSpecification type) {
                  return DropdownMenuItem<TypeSpecification>(
                    value: type,
                    child: Text(type.specification),
                  );
                }).toList(),
                isExpanded:
                    true, // Garantir que o menu suspenso esteja totalmente expandido
              ),
              ListTile(
                title: Text("Filtrar por Período de Data"),
                onTap: () async {
                  Navigator.pop(context);
                  final List<DateTime?>? pickedDates =
                      await showDialog<List<DateTime?>>(
                    context: context,
                    builder: (BuildContext context) {
                      DateTime startDate = _startDateFilter ?? DateTime.now();
                      DateTime endDate = _endDateFilter ?? DateTime.now();
                      return AlertDialog(
                        title: Text("Selecionar Período de Data"),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text("Data de Início"),
                                subtitle: Text(
                                    DateFormat('dd/MM/yyyy').format(startDate)),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null && mounted) {
                                    setState(() {
                                      startDate = pickedDate;
                                    });
                                  }
                                },
                              ),
                              ListTile(
                                title: Text("Data de Fim"),
                                subtitle: Text(
                                    DateFormat('dd/MM/yyyy').format(endDate)),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null && mounted) {
                                    setState(() {
                                      endDate = pickedDate;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, [startDate, endDate]);
                            },
                            child: Text('Filtrar'),
                          ),
                        ],
                      );
                    },
                  );
                  if (pickedDates != null &&
                      pickedDates.length == 2 &&
                      mounted) {
                    setState(() {
                      _startDateFilter = pickedDates[0];
                      _endDateFilter = pickedDates[1];
                      _complaintsFuture = _applyFilters();
                    });
                  }
                },
                selected: _startDateFilter != null || _endDateFilter != null,
              ),
              ElevatedButton(
                onPressed: _selectedStatusFilter != null ||
                        _startDateFilter != null ||
                        _endDateFilter != null ||
                        _selectedTypeSpecification != null ||
                        _selectedComplantTypeFilter != null
                    ? () {
                        Navigator.pop(context);
                        if (mounted) {
                          _complaintsFuture = _applyFilters();
                          setState(() {});
                        }
                      }
                    : null,
                child: Text("Aplicar Filtros"),
                style: ElevatedButton.styleFrom(
                  primary: _selectedStatusFilter != null ||
                          _startDateFilter != null ||
                          _endDateFilter != null ||
                          _selectedTypeSpecification != null ||
                          _selectedComplantTypeFilter != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Complaint>> _applyFilters() async {
    var complaints = await _loadComplaints();

    // Filtrar por status, tipo de reclamação e tipo de especificação
    complaints = complaints.where((complaint) {
      bool statusFilter = _selectedStatusFilter == null ||
          complaint.status == _selectedStatusFilter;
      bool typeFilter = _selectedComplantTypeFilter == null ||
          complaint.complaintType.classification == _selectedComplantTypeFilter;
      bool typeSpecificationFilter = _selectedTypeSpecification == null ||
          complaint.typeSpecification.id == _selectedTypeSpecification?.id;
      return statusFilter && typeFilter && typeSpecificationFilter;
    }).toList();

    // Filtrar por data
    if (_startDateFilter != null && _endDateFilter != null) {
      complaints = complaints.where((complaint) {
        var complaintDate = complaint.date;
        return complaintDate.isAfter(_startDateFilter!) &&
            complaintDate.isBefore(_endDateFilter!.add(Duration(days: 1)));
      }).toList();
    }

    return complaints;
  }

  Future<List<Complaint>> _loadComplaints() async {
    try {
      return await ComplaintMethods().getAllComplaints();
    } catch (error) {
      print("Failed to load complaints: $error");
      return []; // Retorna uma lista vazia em caso de erro
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
                              complaintId: complaint.id.toString(),
                            ),
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
