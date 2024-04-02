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
  XFile? _pickedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(source: source);

    setState(() {
      _pickedImage = pickedImage;
    });
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: _pickedImage != null
                            ? Image.file(
                                File(_pickedImage!.path),
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
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          _pickImage(ImageSource.gallery);
                        },
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
