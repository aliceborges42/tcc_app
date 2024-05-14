import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:tcc_app/resources/data_methods.dart';

class ComplaintsChartsPage extends StatefulWidget {
  const ComplaintsChartsPage({Key? key}) : super(key: key);

  @override
  _ComplaintsChartsPageState createState() => _ComplaintsChartsPageState();
}

class _ComplaintsChartsPageState extends State<ComplaintsChartsPage> {
  List<ChartData> _chartData = [];
  String? _selectedComplaintTypeId;
  String? _selectedTypeSpecificationId;

  @override
  void initState() {
    super.initState();
    // Carrega os dados inicialmente ao iniciar a página
    _loadChartData();
  }

  // Método para carregar os dados do gráfico
  Future<void> _loadChartData() async {
    try {
      // Chama o método para buscar os dados
      Map<String, dynamic> data = await DataMethods().fetchComplaintsByMonth(
        _selectedComplaintTypeId,
        _selectedTypeSpecificationId,
      );

      print(data);
      // Converte os dados recebidos em uma lista de ChartData
      List<ChartData> chartData = _convertToChartData(data);
      setState(() {
        _chartData = chartData;
      });
    } catch (e) {
      // Trata erros ao buscar os dados
      print('Error loading chart data: $e');
    }
  }

  // Método para converter os dados recebidos em ChartData
  List<ChartData> _convertToChartData(Map<String, dynamic> data) {
    List<ChartData> chartData = [];

    // Mapeie os dados para uma lista de ChartData
    data.forEach((key, value) {
      try {
        // Divide a string da data em partes separadas por "-"
        List<String> parts = key.split("-");
        if (parts.length == 2) {
          // Se a data só tem ano e mês, adiciona o dia 1 para criar uma data válida
          key += "-01";
        }
        DateTime dateTime = DateTime.parse(key);
        chartData.add(ChartData(dateTime, value as int));
      } catch (e) {
        print('Error parsing date: $e');
      }
    });

    // Ordena os dados por data
    chartData.sort((a, b) => a.x.compareTo(b.x));

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown para seleção do tipo de reclamação
        SizedBox(
          height: 16,
        ),

        const Text(
          'Desordens e Incidentes por Mês e Ano',
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
        // Dropdown para seleção da especificação do tipo
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
        // Botão para atualizar o gráfico com os dados selecionados
        ElevatedButton(
          onPressed: _loadChartData,
          child: Text('Atualizar Gráfico'),
        ),
        SfCartesianChart(
          // Define data source for the chart
          series: <LineSeries<ChartData, DateTime>>[
            LineSeries<ChartData, DateTime>(
              dataSource: _chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Número de Desordens e Episódios',
              color: Colors.blue,
              width: 2,
              markerSettings: MarkerSettings(isVisible: true),
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
          // Define axis properties
          primaryXAxis: DateTimeAxis(
            title: AxisTitle(text: 'Mês e ano'),
            // dateFormat: DateFormat.yMMM(),
            dateFormat: DateFormat.yM(),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Número de Desordens e Episódios'),
          ),
          // Optional: Add tooltip behavior
          tooltipBehavior: TooltipBehavior(enable: true),
        ),
      ],
    );
  }

  // Método para construir os itens do dropdown de tipo de reclamação
  Future<List<DropdownMenuItem<String>>>
      _buildComplaintTypeDropdownItems() async {
    // Lista de itens do dropdown
    List<DropdownMenuItem<String>> items = [];

    // Chamada assíncrona para buscar os tipos de reclamação
    try {
      List<ComplaintType> complaintTypes =
          await ComplaintMethods().getComplaintTypes();
      // Itera sobre os tipos de reclamação recebidos
      for (ComplaintType complaintType in complaintTypes) {
        // Adiciona um item ao dropdown com o ID como valor e a classificação como rótulo
        items.add(DropdownMenuItem(
          value: complaintType.id.toString(),
          child: Text(complaintType.classification),
        ));
      }
    } catch (error) {
      // Trata erros ao buscar os tipos de reclamação
      print('Error loading complaint types: $error');
    }

    // Retorna a lista de itens do dropdown
    return items;
  }

  // Método para construir os itens do dropdown de especificação do tipo
  Future<List<DropdownMenuItem<String>>>
      _buildTypeSpecificationDropdownItems() async {
    // Lista de itens do dropdown
    List<DropdownMenuItem<String>> items = [];

    // Chamada assíncrona para buscar as especificações do tipo
    try {
      List<TypeSpecification> typeSpecifications =
          await ComplaintMethods().getTypeSpecifications();
      // Itera sobre as especificações do tipo recebidas
      for (TypeSpecification typeSpecification in typeSpecifications) {
        // Adiciona um item ao dropdown com o ID como valor e a especificação como rótulo
        items.add(DropdownMenuItem(
          value: typeSpecification.id.toString(),
          child: Text(typeSpecification.specification),
        ));
      }
    } catch (error) {
      // Trata erros ao buscar as especificações do tipo
      print('Error loading type specifications: $error');
    }

    // Retorna a lista de itens do dropdown
    return items;
  }
}

class ChartData {
  final DateTime x;
  final int y;

  ChartData(this.x, this.y);
}
