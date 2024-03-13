import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/complaint/choose_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_app/resources/firestore_methods.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/utils/colors.dart';
import 'package:tcc_app/utils/global_variable.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/components/my_textfield.dart';

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

  final desordemItems = [
    'Poste de Luz Danificado',
    'Ausência de Iluminação',
    'Local Depredado'
  ];

  final situacaoItems = [
    'Assédio Sexual',
    'Violência contra a Mulher',
    'Assédio Moral',
    'Estupro'
  ];

  void sendComplaint() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      try {
        GeoPoint? geoPoint;
        if (_selectedLocation != null) {
          geoPoint = GeoPoint(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          );
        }
        final res = await FireStoreMethods().uploadPost(
          formData['descricao'],
          formData['images']!,
          authuser.uid,
          geoPoint,
          formData['dataOcorrido'],
          formData['horaOcorrido'],
          formData['tipoDenuncia'],
          formData['tipoEspecificacao'],
        );
        print('res: $res');
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilderTextField(
              name: 'descricao',
              decoration: myDecoration.copyWith(
                hintText:
                    "Descrição", // Atualizando o hintText com o texto fornecido
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
                hintText:
                    "Tipo de Denúncia", // Atualizando o hintText com o texto fornecido
              ),
              // hint: Text('Selecione o tipo de denúncia'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              items: ['Desordem', 'Situação']
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
            if (complaintType != '')
              FormBuilderDropdown(
                name: 'tipoEspecificacao',
                decoration:
                    InputDecoration(labelText: 'Desordem ou situação ocorrida'),
                // hint: Text('Selecione o tipo de desordem'),
                items: (complaintType == 'Desordem'
                        ? desordemItems
                        : situacaoItems)
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        ))
                    .toList(),
              ),
            const SizedBox(
              height: 12,
            ),
            FormBuilderDateTimePicker(
              name: 'dataOcorrido',
              inputType: InputType.date,
              format: DateFormat('dd/MM/yyyy'),
              decoration: myDecoration.copyWith(
                hintText:
                    "Data do Ocorrido", // Atualizando o hintText com o texto fornecido
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
                hintText:
                    "Hora do Ocorrido", // Atualizando o hintText com o texto fornecido
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
                  side: BorderSide(color: lightBlack), // Define a cor da borda
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

            SizedBox(height: 32),

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
    );
  }
}
