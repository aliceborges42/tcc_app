import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tcc_app/complaint/choose_location.dart';
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
  String complaintType = '';
  bool _isLoading = false;
  List<dynamic> desordemItems = [];
  List<dynamic> situacaoItems = [];
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    fetchTypeSpecifications();
  }

  Future<void> fetchTypeSpecifications() async {
    try {
      List<TypeSpecification> typeSpecifications =
          await ComplaintMethods().getTypeSpecifications();

      List<String> specifications =
          typeSpecifications.map((typeSpec) => typeSpec.specification).toList();

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
      return [];
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        setState(() {
          if (_images.length < 5) {
            _images.add(image);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Limite máximo de 5 imagens atingido.'),
                backgroundColor: Colors.red[700],
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permissão Negada'),
          content: const Text(
              'Por favor, conceda permissão para acessar a câmera e a galeria.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final List<Permission> permissions = [Permission.camera, Permission.photos];
    final Map<Permission, PermissionStatus> permissionStatuses =
        await permissions.request();
    return permissionStatuses[Permission.camera]!;
  }

  void sendComplaint() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione uma localização.'),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      try {
        await ComplaintMethods().postComplaint(
          description: formData['descricao'],
          complaintTypeId: formData['tipoDenuncia'],
          typeSpecificationId: formData['tipoEspecificacao'],
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          hour: formData['horaOcorrido'],
          date: formData['dataOcorrido'],
          images: _images,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Denúncia enviada com sucesso!'),
            backgroundColor: Colors.green[700],
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _isLoading = false;
          _formKey.currentState!.reset();
          _selectedLocation = null;
          _images = [];
        });
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro ao enviar a denúncia. Tente novamente mais tarde.'),
            backgroundColor: Colors.red[700],
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 2),
        ),
      );
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
                    decoration: myDecorationdois(
                      labelText: "Descrição",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório.";
                      }
                      return null;
                    }),
                const SizedBox(height: 12),
                FormBuilderDropdown(
                  name: 'tipoDenuncia',
                  decoration: myDecorationdois(
                    labelText: "Tipo de Denúncia",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obrigatório.";
                    }
                    return null;
                  },
                  items: ['Desordem', 'Episódio']
                      .map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          ))
                      .toList(),
                  onChanged: (tipo) {
                    setState(() {
                      complaintType = tipo ?? '';
                    });
                  },
                ),
                const SizedBox(height: 12),
                FormBuilderDropdown(
                  name: 'tipoEspecificacao',
                  decoration: myDecorationdois(
                    labelText: "Especificação",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório.';
                    }
                    return null;
                  },
                  items: _getDropdownItems(),
                ),
                const SizedBox(height: 12),
                FormBuilderDateTimePicker(
                    name: 'dataOcorrido',
                    inputType: InputType.date,
                    format: DateFormat('dd/MM/yyyy'),
                    decoration: myDecorationdois(
                      labelText: "Data do Ocorrido",
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Campo obrigatório.";
                      }
                      return null;
                    }),
                const SizedBox(height: 12),
                FormBuilderDateTimePicker(
                    name: 'horaOcorrido',
                    inputType: InputType.time,
                    decoration: myDecorationdois(
                      labelText: "Hora do Ocorrido",
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Campo obrigatório.";
                      }
                      return null;
                    }),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _images.map((XFile image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(image.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.remove(image);
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                  semanticLabel: 'Excluir imagem',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Tirar Foto'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _getImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.image),
                                title: const Text('Selecionar da Galeria'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _getImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Adicionar Imagem'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: lightBlack),
                    ),
                  ),
                  onPressed: () async {
                    LatLng? selectedLocation = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const ChooseLocationMap();
                      },
                    );

                    if (selectedLocation != null) {
                      setState(() {
                        _selectedLocation = selectedLocation;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Localização é obrigatória.'),
                          backgroundColor: Colors.red[700],
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Escolher Localização'),
                ),
                if (_selectedLocation != null)
                  Text('Localização Selecionada: $_selectedLocation'),
                SizedBox(height: 24),
                MyButton(
                    onTap: sendComplaint,
                    buttonText: 'Enviar Denúncia',
                    isLoading: _isLoading)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
