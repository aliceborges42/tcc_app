import 'package:flutter/material.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/pages/login_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/utils/global_variable.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
// import 'package:cpf_cnpj_validator/cpf_validator.dart' as cpf_cnpj_validator;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    cpfController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void signUp() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate CPF
      if (!isValidCPF(cpfController.text)) {
        throw Exception('Invalid CPF');
      }

      String res = await AuthMethods().signUpUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        cpf: cpfController.text,
      );

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        // navigate to the home screen
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    } on Exception catch (error) {
      // make it explicit that this function can throw exceptions
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(context, error.toString());
      }
    }
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  bool isValidCPF(String cpf) {
    // Regex for CPF validation
    // final RegExp cpfRegex = RegExp(
    //     r'^([0-9]{3}\.?[0-9]{3}\.?[0-9]{3}\-?[0-9]{2})|([0-9]{11})$');
    return CPFValidator.isValid(cpf);
  }

  // wrong email message popup
  void emailAlreadyExistsMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.orangeAccent,
          title: Center(
            child: Text(
              'Email already in use',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void passwordNotConfirmed() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Password not confirmed',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // wrong password message popup
  void invalidEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Email address is not valid',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(shrinkWrap: true, children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // logo
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  const Text('Atenta App',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 30),

                  const Text(
                    'Cadastro',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 25),

                  // email textfield
                  TextField(
                    controller: nameController,
                    decoration: myDecoration.copyWith(
                      labelText: "Nome e Sobrenome",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ), // Atualizando o hintText com o texto fornecido
                    ),
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: cpfController,
                    // hintText: 'CPF',
                    decoration: myDecoration.copyWith(
                      labelText: "CPF",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ), // Atualizando o hintText com o texto fornecido
                    ),
                    inputFormatters: [
                      // obrigatório
                      FilteringTextInputFormatter.digitsOnly,
                      CpfInputFormatter(),
                    ],
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: myDecoration.copyWith(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ), // Atualizando o hintText com o texto fornecido
                    ),
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  TextField(
                    controller: passwordController,
                    decoration: myDecoration.copyWith(
                      labelText: "Senha",
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
                  ),

                  const SizedBox(height: 10),

                  // confirm password textfield
                  TextField(
                    controller: confirmPasswordController,
                    decoration: myDecoration.copyWith(
                      labelText: "Confirme sua senha",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: toggleConfirmPasswordVisibility,
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    onTap: signUp,
                    buttonText: "Criar conta",
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 30),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já possui conta?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        ),
                        child: const Text(
                          'Login now',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  showSnackBar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
