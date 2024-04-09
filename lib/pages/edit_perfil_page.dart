import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_app/models/user_model.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/utils/global_variable.dart';
import 'package:tcc_app/components/my_button.dart';

class PerfilEditPage extends StatefulWidget {
  final User user;

  const PerfilEditPage({Key? key, required this.user}) : super(key: key);

  @override
  _PerfilEditPageState createState() => _PerfilEditPageState();
}

class _PerfilEditPageState extends State<PerfilEditPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _pickedImage;
  double _imageScale = 1.0;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      print('Imagem selecionada: ${_pickedImage!.path}');
    } else {
      print('Nenhuma imagem selecionada.');
    }
  }

  void updateUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      try {
        await AuthMethods().updateUser(
          name: formData['Name'],
          email: formData['email'],
          cpf: formData['cpf'],
          password: formData['password'],
          avatar: _pickedImage,
        );
      } catch (err) {
        print(err);
      }
      setState(() {
        _isLoading = false;
      });
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onScaleUpdate: (details) {
                          setState(() {
                            _imageScale = details.scale;
                          });
                        },
                        child: ClipOval(
                          child: Container(
                            width: 150 * _imageScale,
                            height: 150 * _imageScale,
                            color: Colors.grey[200],
                            child: _pickedImage != null
                                ? Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : widget.user.avatar != null
                                    ? Image.network(
                                        widget.user.avatar!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            print('Selecionar imagem da galeria.');
                            _pickImage(ImageSource.gallery);
                          },
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  FormBuilderTextField(
                    name: 'Name',
                    initialValue: widget.user.name,
                    decoration: myDecoration.copyWith(
                      hintText: "Nome",
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'email',
                    initialValue: widget.user.email,
                    decoration: myDecoration.copyWith(
                      hintText: "Email",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'cpf',
                    initialValue: widget.user.cpf,
                    decoration: myDecoration.copyWith(
                      hintText: "CPF",
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'password',
                    decoration: myDecoration.copyWith(
                      hintText: "Confirme sua Senha",
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 12),
                  MyButton(
                    onTap: updateUser,
                    buttonText: 'Salvar',
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
