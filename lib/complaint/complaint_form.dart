import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/complaint/choose_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/utils/colors.dart';
import 'package:tcc_app/utils/global_variable.dart';
import 'package:tcc_app/components/my_button.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  LatLng? _selectedLocation;
  final authuser = FirebaseAuth.instance.currentUser!;
  String complaintType = '';
  bool _isLoading = false;
  List<dynamic> desordemItems = [];
  List<dynamic> situacaoItems = [];

  @override
  void initState() {
    super.initState();
    fetchTypeSpecifications(); // Chama o método no momento da inicialização do estado
  }

  Future<void> fetchTypeSpecifications() async {
    try {
      List<TypeSpecification> typeSpecifications =
          await ComplaintMethods().getTypeSpecifications();

      // Mapeando apenas o campo 'specification' para cada objeto TypeSpecification
      List<String> specifications =
          typeSpecifications.map((typeSpec) => typeSpec.specification).toList();

      // Dividindo as especificações entre situaçãoItems e desordemItems
      setState(() {
        situacaoItems = specifications.sublist(0, 10);
        desordemItems = specifications.sublist(10);
      });
    } catch (e) {
      print(e);
    }
  }

  List<DropdownMenuItem<dynamic>> _getDropdownItems() {
    if (complaintType == 'Desordem') {
      return desordemItems
          .map((item) => DropdownMenuItem(
                value: item.toString(),
                child: Text(item.toString()),
              ))
          .toList();
    } else if (complaintType == 'Episódio') {
      return situacaoItems
          .map((item) => DropdownMenuItem(
                value: item.toString(),
                child: Text(item.toString()),
              ))
          .toList();
    } else {
      return []; // Retornar uma lista vazia se nenhum tipo de denúncia estiver selecionado
    }
  }

  void sendComplaint() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      List<dynamic>? images = formData['images'];
      try {
        // print('\n\n\n-----------------------\n\n\n');
        await ComplaintMethods().postComplaint(
          description: formData['descricao'],
          complaintTypeId: formData['tipoDenuncia'],
          typeSpecificationId: formData['tipoEspecificacao'],
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          hour: formData['horaOcorrido'],
          date: formData['dataOcorrido'],
          images: images,
        );

        // print('sres: $res');
        // print('res: $resAPI');
        // if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        print(err);
      }
      setState(() {
        _isLoading = false;
      });
      _formKey.currentState!.reset();
      _selectedLocation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: 'descricao',
                  decoration: myDecoration.copyWith(
                    labelText: "Descrição",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ), // Atualizando o hintText com o texto fornecido
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(
                  height: 12,
                ),
                FormBuilderDropdown(
                  name: 'tipoDenuncia',
                  // decoration: InputDecoration(labelText: 'Tipo de Denúncia'),
                  decoration: myDecoration.copyWith(
                    labelText:
                        "Tipo de Denúncia", // Atualizando o hintText com o texto fornecido
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  // hint: Text('Selecione o tipo de denúncia'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  items: ['Desordem', 'Episódio']
                      .map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          ))
                      .toList(),
                  onChanged: (tipo) {
                    print("Tipo selecionado: $tipo");
                    setState(() {
                      complaintType = tipo ?? ''; // Ou atribua um valor padrão
                    });
                  },
                ),
                // Adicionar campo 2.1 (seleção condicional)
                const SizedBox(
                  height: 12,
                ),
                FormBuilderDropdown(
                  name: 'tipoEspecificacao',
                  decoration: myDecoration.copyWith(
                    labelText:
                        "Especificação", // Atualizando o hintText com o texto fornecido
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  items: _getDropdownItems(),
                ),
                const SizedBox(
                  height: 12,
                ),
                FormBuilderDateTimePicker(
                  name: 'dataOcorrido',
                  inputType: InputType.date,
                  format: DateFormat('dd/MM/yyyy'),
                  decoration: myDecoration.copyWith(
                    labelText:
                        "Data do Ocorrido", // Atualizando o hintText com o texto fornecido
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(
                  height: 12,
                ),
                FormBuilderDateTimePicker(
                  name: 'horaOcorrido',
                  inputType: InputType.time,
                  decoration: myDecoration.copyWith(
                    labelText:
                        "Hora do Ocorrido", // Atualizando o hintText com o texto fornecido
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                FormBuilderImagePicker(
                  name: 'images',
                  decoration: myDecoration.copyWith(
                    labelText:
                        "Imagens do Local", // Atualizando o hintText com o texto fornecido
                  ),
                  backgroundColor: Colors.grey[200],
                  iconColor: Colors.grey[800],
                  maxImages: 5,
                ),
                const SizedBox(
                  height: 12,
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor:
                        Colors.white, // Define a cor do texto como preto
                    elevation: 0, // Define a elevação do botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Define o raio do canto do botão
                      side: BorderSide(
                          color: lightBlack), // Define a cor da borda
                    ),
                  ),
                  onPressed: () async {
                    // Abrir o diálogo do mapa
                    LatLng? selectedLocation = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const ChooseLocationMap();
                      },
                    );

                    // Atualizar a localização selecionada no formulário
                    if (selectedLocation != null) {
                      setState(() {
                        _selectedLocation = selectedLocation;
                      });
                    }
                  },
                  child: const Text('Escolher Localização'),
                ),

                // Exibir a localização selecionada (opcional)
                if (_selectedLocation != null)
                  Text('Localização Selecionada: $_selectedLocation'),

                SizedBox(height: 24),

                MyButton(
                    onTap: sendComplaint,
                    buttonText: 'Enviar Denúncia',
                    isLoading: _isLoading)
                // ElevatedButton(
                //   onPressed: () async {
                //     if (_formKey.currentState!.saveAndValidate()) {
                //       Map<String, dynamic> formData = _formKey.currentState!.value;
                //       try {
                //         GeoPoint? geoPoint;
                //         if (_selectedLocation != null) {
                //           geoPoint = GeoPoint(
                //             _selectedLocation!.latitude,
                //             _selectedLocation!.longitude,
                //           );
                //         }
                //         final res = await FireStoreMethods().uploadPost(
                //           formData['descricao'],
                //           formData['images']!,
                //           authuser.uid,
                //           geoPoint,
                //           formData['dataOcorrido'],
                //           formData['horaOcorrido'],
                //           formData['tipoDenuncia'],
                //           formData['tipoEspecificacao'],
                //         );
                //         print('res: $res');
                //       } catch (err) {
                //         print(err);
                //       }
                //       _formKey.currentState!.reset();
                //     }
                //   },
                //   child: Text('Enviar Denúncia'),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
