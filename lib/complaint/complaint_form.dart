import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/complaint/choose_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_app/resources/firestore_methods.dart';
// Se necessário, ajuste o caminho para Complaint dependendo da estrutura do seu projeto
import 'package:tcc_app/models/complaint_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  LatLng? _selectedLocation;
  final authuser = FirebaseAuth.instance.currentUser!;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'descricao',
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),

            FormBuilderDateTimePicker(
              name: 'dataOcorrido',
              inputType: InputType.date,
              decoration: InputDecoration(labelText: 'Data do Ocorrido'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            FormBuilderDateTimePicker(
              name: 'horaOcorrido',
              inputType: InputType.time,
              decoration: InputDecoration(labelText: 'Hora do Ocorrido'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            FormBuilderImagePicker(
              name: 'images',
              decoration: const InputDecoration(labelText: 'Imagens do Local'),
              maxImages: 5,
            ),
            // Outros campos do formulário (data, hora, imagens, localização) aqui
            // Use FormBuilderDateTimePicker para data e hora
            // Use FormBuilderImagePicker para imagens
            // Use FormBuilderGoogleMap para selecionar a localização no mapa
            // ...
            ElevatedButton(
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

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.saveAndValidate()) {
                  // Obter dados do formulário
                  Map<String, dynamic> formData = _formKey.currentState!.value;
                  // print(formData);
                  try {
                    String complaintId = const Uuid().v1();
                    GeoPoint? geoPoint;
                    if (_selectedLocation != null) {
                      geoPoint = GeoPoint(_selectedLocation!.latitude,
                          _selectedLocation!.longitude);
                    }
                    // final complaint = {'local': geoPoint};
                    // final user = FirebaseFirestore.instance
                    //     .collection('user')
                    //     .doc(authuser.uid)
                    //     .get();
                    // print('user: $user');
                    final res = await FireStoreMethods().uploadPost(
                        formData['descricao'],
                        formData['images']!,
                        authuser.uid,
                        geoPoint,
                        formData['dataOcorrido'],
                        formData['horaOcorrido']);

                    print('res: $res');

                    // _firestore
                    //     .collection('complaints')
                    //     .doc(complaintId)
                    //     .set(complaint);
                  } catch (err) {
                    print(err);
                  }
                  // Complaint newComplaint = Complaint(
                  //   description: formData['descricao'],
                  //   // Obter outros campos do formulário
                  //   // ...
                  // {
                  //  descricao: popopo,
                  //  dataOcorrido: 2023-11-22 00:00:00.000,
                  //  horaOcorrido: 0001-01-01 10:00:00.000,
                  //  images: [Instance of 'XFile', Instance of 'XFile']

                  //   // Supondo que você tenha uma função para adicionar denúncia ao Firebase
                  //   // AdicionarDenunciaAoFirebase(novaDenuncia);
                  // );

                  // Limpar o formulário após a submissão
                  _formKey.currentState!.reset();
                }
              },
              child: Text('Enviar Denúncia'),
            ),
          ],
        ),
      ),
    );
  }
}
