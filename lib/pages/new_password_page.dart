import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/utils/global_variable.dart';
import 'package:tcc_app/components/my_button.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({Key? key}) : super(key: key);

  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void updatePassword() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = _formKey.currentState!.value;
      try {
        await AuthMethods().updatePassword(
          currentPassowrd: formData['currentPassword'],
          newPassword: formData['newPassword'],
          passwordConfirmation: formData['passwordConfirmation'],
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
        title: Text('Alterar Senha'),
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
                  SizedBox(height: 16.0),
                  FormBuilderTextField(
                    name: 'currentPassword',
                    obscureText: true, // Torna o campo de senha
                    decoration: myDecoration.copyWith(
                      hintText: "Senha Atual",
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'newPassword',
                    obscureText: true, // Torna o campo de senha
                    decoration: myDecoration.copyWith(
                      hintText: "Nova Senha",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'passwordConfirmation',
                    obscureText: true, // Torna o campo de senha
                    decoration: myDecoration.copyWith(
                      hintText: "Confirme sua Senha",
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 12),
                  MyButton(
                    onTap: updatePassword,
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
