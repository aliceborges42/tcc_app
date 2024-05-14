import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:tcc_app/resources/data_methods.dart';

class ResolutionsChart extends StatefulWidget {
  const ResolutionsChart({Key? key}) : super(key: key);

  @override
  _ResolutionsChartState createState() => _ResolutionsChartState();
}

class _ResolutionsChartState extends State<ResolutionsChart> {
  List<ChartData> _chartData = [];
  String? _selectedComplaintTypeId;
  String? _selectedTypeSpecificationId;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    try {
      Map<String, dynamic> data =
          await DataMethods().fetchResolutionRateByMonth(
        _selectedComplaintTypeId,
        _selectedTypeSpecificationId,
      );

      print(data);
      List<ChartData> chartData = _convertToChartData(data);
      setState(() {
        _chartData = chartData;
      });
    } catch (e) {
      print('Error loading chart data: $e');
    }
  }

  List<ChartData> _convertToChartData(Map<String, dynamic> data) {
    List<ChartData> chartData = [];

    data.forEach((key, value) {
      try {
        // Utilize DateFormat para formatar a data recebida
        DateTime dateTime = DateFormat('yyyy-M').parse(key);
        chartData.add(ChartData(dateTime, value as int));
      } catch (e) {
        print('Error parsing date: $e');
      }
    });

    chartData.sort((a, b) => a.x.compareTo(b.x));

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        const Text(
          'Resoluções de Denúncias por Mês e Ano',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 16,
        ),
        FutureBuilder<List<DropdownMenuItem<String>>>(
          future: _buildComplaintTypeDropdownItems(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DropdownButtonFormField<String>(
                value: _selectedComplaintTypeId,
                onChanged: (value) {
                  setState(() {
                    _selectedComplaintTypeId = value;
                  });
                  _loadChartData();
                },
                items: snapshot.data!,
                decoration: InputDecoration(labelText: 'Tipo de Reclamação'),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        FutureBuilder<List<DropdownMenuItem<String>>>(
          future: _buildTypeSpecificationDropdownItems(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DropdownButtonFormField<String>(
                value: _selectedTypeSpecificationId,
                onChanged: (value) {
                  setState(() {
                    _selectedTypeSpecificationId = value;
                  });
                  _loadChartData();
                },
                items: snapshot.data!,
                decoration: InputDecoration(labelText: 'Especificação do Tipo'),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        ElevatedButton(
          onPressed: _loadChartData,
          child: Text('Atualizar Gráfico'),
        ),
        Expanded(
          child: SfCartesianChart(
            series: <LineSeries<ChartData, String>>[
              LineSeries<ChartData, String>(
                dataSource: _chartData,
                xValueMapper: (ChartData data, _) =>
                    DateFormat('MM/yyyy').format(data.x),
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Resoluções',
                color: Colors.blue,
                width: 2,
                markerSettings: MarkerSettings(isVisible: true),
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
            primaryXAxis: CategoryAxis(
              title: AxisTitle(text: 'Mês e ano'),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Resoluções'),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ],
    );
  }

  Future<List<DropdownMenuItem<String>>>
      _buildComplaintTypeDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      List<ComplaintType> complaintTypes =
          await ComplaintMethods().getComplaintTypes();
      for (ComplaintType complaintType in complaintTypes) {
        items.add(DropdownMenuItem(
          value: complaintType.id.toString(),
          child: Text(complaintType.classification),
        ));
      }
    } catch (error) {
      print('Error loading complaint types: $error');
    }

    return items;
  }

  Future<List<DropdownMenuItem<String>>>
      _buildTypeSpecificationDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      List<TypeSpecification> typeSpecifications =
          await ComplaintMethods().getTypeSpecifications();
      for (TypeSpecification typeSpecification in typeSpecifications) {
        items.add(DropdownMenuItem(
          value: typeSpecification.id.toString(),
          child: Text(typeSpecification.specification),
        ));
      }
    } catch (error) {
      print('Error loading type specifications: $error');
    }

    return items;
  }
}

class ChartData {
  final DateTime x;
  final int y;

  ChartData(this.x, this.y);
}
