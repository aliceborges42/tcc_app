import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/complaint/choose_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/pages/complaint_page.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/utils/colors.dart';
import 'package:tcc_app/utils/global_variable.dart';
import 'package:tcc_app/components/my_button.dart';

class ComplaintEditForm extends StatefulWidget {
  final Complaint complaint;

  const ComplaintEditForm({Key? key, required this.complaint})
      : super(key: key);

  @override
  _ComplaintEditFormState createState() => _ComplaintEditFormState();
}

class _ComplaintEditFormState extends State<ComplaintEditForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  LatLng? _selectedLocation;
  final authUser = FirebaseAuth.instance.currentUser!;
  String complaintType = '';
  String initialSpecification = '';
  bool _isLoading = false;
  List<dynamic> desordemItems = [];
  List<dynamic> situacaoItems = [];
  final List<int> _imagesToDelete = [];
  TypeSpecification? initialTypeSpecification;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    fetchTypeSpecifications();
    _setSelectedState();
    complaintType = widget.complaint.complaintType.classification;
    initialSpecification = widget.complaint.typeSpecification.specification;
  }

  void _setSelectedState() {
    _selectedLocation = LatLng(
      widget.complaint.latitude,
      widget.complaint.longitude,
    );
  }

  // Fetch type specifications from API
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
      print("Error fetching type specifications: $e");
    }
  }

  // Remove image from deletion list
  void _removeImageToDelete(int imageId) {
    setState(() {
      _imagesToDelete.remove(imageId);
    });
  }

  // Add image to deletion list
  void _addImageToDelete(int imageId) {
    setState(() {
      _imagesToDelete.add(imageId);
    });
  }

  // Get dropdown items based on complaint type
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

  // Build complaint images widget
  Widget _buildComplaintImages() {
    if (widget.complaint.images!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imagens da Reclamação:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.complaint.images!.map((image) {
              return Stack(
                children: [
                  Image.network(
                    image.url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (!_imagesToDelete.contains(image.id)) {
                          _addImageToDelete(image.id);
                        } else {
                          _removeImageToDelete(image.id);
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _imagesToDelete.contains(image.id)
                              ? Colors.red
                              : Colors.grey.withOpacity(0.7),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  String? _getInitialTypeSpecification() {
    if (complaintType == 'Desordem') {
      return desordemItems.firstWhere(
          (spec) => spec == widget.complaint.typeSpecification.specification);
    } else if (complaintType == 'Episódio') {
      return situacaoItems.firstWhere(
          (spec) => spec == widget.complaint.typeSpecification.specification);
    } else {
      return null;
    }
  }

  // Send complaint to server
  void sendComplaint() async {
    print('veio sand');
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      List<dynamic>? images = formData['images'];

      formData.forEach((key, value) {
        print('$key: $value');
      });
      print(widget.complaint.id.toString());

      try {
        await ComplaintMethods().updateComplaint(
          complaintId: widget.complaint.id.toString(),
          description: formData['descricao'] != widget.complaint.description
              ? formData['descricao']
              : null,
          complaintTypeId: formData['tipoDenuncia'] !=
                  widget.complaint.complaintType.classification
              ? formData['tipoDenuncia']
              : null,
          typeSpecificationId: formData['tipoEspecificacao'] !=
                  widget.complaint.typeSpecification.specification
              ? formData['tipoEspecificacao']
              : null,
          date: formData['dataOcorrido'] != widget.complaint.date
              ? formData['dataOcorrido']
              : null,
          hour: formData['horaOcorrido'] != widget.complaint.hour
              ? formData['horaOcorrido']
              : null,
          images: images,
          removedImagesIds: _imagesToDelete.isNotEmpty ? _imagesToDelete : null,
          status: formData['status'] != widget.complaint.status
              ? formData['status']
              : null,
        );

        // Após a atualização bem-sucedida, navegamos para a página de reclamação
        print('deu bom');
      } catch (err) {
        print("Error sending complaint: $err");
      }
    }

    setState(() {
      _isLoading = false;
    });
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
                FormBuilderDropdown(
                  name: 'status',
                  initialValue: widget.complaint.status,
                  decoration: myDecoration.copyWith(
                    labelText: "Status",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ), // Atualizando o hintText com o texto fornecido
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  items: ['Resolvido', 'Não Resolvido']
                      .map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'descricao',
                  initialValue: widget.complaint.description,
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
                const SizedBox(height: 12),
                FormBuilderDropdown(
                  name: 'tipoDenuncia',
                  initialValue: complaintType,
                  decoration: myDecoration.copyWith(
                    labelText:
                        "Tipo de Denúncia", // Atualizando o hintText com o texto fornecido
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    setState(() {
                      complaintType = tipo ?? '';
                    });
                  },
                ),
                const SizedBox(height: 12),
                FormBuilderDropdown(
                  name: 'tipoEspecificacao',
                  initialValue: initialSpecification,
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
                const SizedBox(height: 12),
                FormBuilderDateTimePicker(
                  name: 'dataOcorrido',
                  initialValue: widget.complaint.date,
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
                const SizedBox(height: 12),
                FormBuilderDateTimePicker(
                  name: 'horaOcorrido',
                  initialValue: widget.complaint.hour,
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
                const SizedBox(height: 20),
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
                SizedBox(height: 12),
                _buildComplaintImages(),
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
                    }
                  },
                  child: const Text('Escolher Localização'),
                ),
                if (_selectedLocation != null)
                  Text('Localização Selecionada: $_selectedLocation'),
                SizedBox(height: 24),
                MyButton(
                  onTap: sendComplaint,
                  buttonText: 'Editar Denúncia',
                  isLoading: _isLoading,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
