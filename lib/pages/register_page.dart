import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/pages/login_page.dart';
import 'package:tcc_app/pages/privacy_policy.dart';
import 'package:tcc_app/pages/term_of_use.dart';
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
  bool _agreedToTerms = false;

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

      // Check if user agreed to terms
      if (!_agreedToTerms) {
        throw Exception(
            'Por favor, concorde com os Termos de Uso e a Política de Privacidade');
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
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alinha a coluna à esquerda
                children: [
                  const SizedBox(height: 4),
                  // logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          // Icon(
                          //   Icons.lock,
                          //   size: 80,
                          // ),
                          Image.asset(
                            'assets/images/Group 22 (1).png',
                            height: 150,
                            // width: 150,
                          ),
                          // Text('Atenta UnB',
                          //     style: TextStyle(
                          //         fontSize: 26, fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          Text(
                            'Cadastro',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // email textfield
                  TextField(
                    controller: nameController,
                    decoration: myDecoration.copyWith(
                      labelText: "Nome e Sobrenome",
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: cpfController,
                    decoration: myDecoration.copyWith(
                      labelText: "CPF",
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    inputFormatters: [
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
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  // password textfield
                  TextField(
                    controller: passwordController,
                    decoration: myDecoration.copyWith(
                      labelText: "Senha",
                      labelStyle: const TextStyle(
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
                      labelStyle: const TextStyle(
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
                  const SizedBox(height: 10),
                  // checkbox for terms agreement
                  Wrap(
                    alignment: WrapAlignment.start, // Alinha o Wrap à esquerda
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value!;
                            });
                          },
                          activeColor: Colors.deepPurple),
                      const Text(
                        'Concordo com os ',
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navegar para a página de Termos de Uso quando o texto for clicado
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TermsOfUsePage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Termos de Uso',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Text(
                        ' e a ',
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navegar para a página de Política de Privacidade quando o texto for clicado
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Política de Privacidade',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // sign in button
                  MyButton(
                    onTap: signUp,
                    buttonText: "Criar conta",
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 15),
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
                          'Faça o Login',
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
            ],
          ),
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
