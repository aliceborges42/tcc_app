import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isPasswordVisible = false;

  Future<void> _pickImage(ImageSource source) async {
    final PermissionStatus permissionStatus = await _getPermission();

    if (permissionStatus == PermissionStatus.granted) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);

      if (pickedImage != null) {
        setState(() {
          _pickedImage = File(pickedImage.path);
        });
        print('Imagem selecionada: ${_pickedImage!.path}');
      } else {
        print('Nenhuma imagem selecionada.');
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

  bool isValidCPF(String cpf) {
    // Regex for CPF validation
    // final RegExp cpfRegex = RegExp(
    //     r'^([0-9]{3}\.?[0-9]{3}\.?[0-9]{3}\-?[0-9]{2})|([0-9]{11})$');
    return CPFValidator.isValid(cpf);
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void updateUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      try {
        if (!isValidCPF(formData['cpf'])) {
          throw Exception('Invalid CPF');
        }
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
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 1,
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
                          onTap: () async {
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
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.image),
                                      title:
                                          const Text('Selecionar da Galeria'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
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
                      labelText: "Nome",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'email',
                    initialValue: widget.user.email,
                    decoration: myDecoration.copyWith(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'cpf',
                    decoration: myDecoration.copyWith(
                      labelText: "CPF",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    inputFormatters: [
                      // obrigatório
                      FilteringTextInputFormatter.digitsOnly,
                      CpfInputFormatter(),
                    ],
                    initialValue: widget.user.cpf,
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 28),
                  Text(
                    'Confirme sua senha para salvar as alterações:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  FormBuilderTextField(
                    name: 'password',
                    decoration: myDecoration.copyWith(
                      labelText: "Confirme sua Senha",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: togglePasswordVisibility,
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
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
