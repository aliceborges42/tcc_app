import 'package:flutter/material.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/pages/forgot_pw_page.dart';
import 'package:tcc_app/pages/home_page.dart';
import 'package:tcc_app/pages/register_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/utils/global_variable.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthMethods().loginUser(
          email: emailController.text, password: passwordController.text);
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        setState(() {
          _isLoading = false;
        });
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
                  Semantics(
                    label: 'Logotipo Atenta UnB',
                    // 'Logotipo Atenta UnB' deve ser substituído por uma descrição mais apropriada, se necessário
                    hint: 'Imagem do logotipo da Atenta UnB',
                    child: Image.asset(
                      'assets/images/Group 22 (1).png',
                      height: 150,
                    ),
                    // O 'hint' é opcional e pode ser usado para fornecer informações adicionais sobre a ação ou contexto da imagem
                  ),
                  const SizedBox(height: 20),

                  // welcome back, you've been missed!
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  // email textfield
                  TextField(
                    controller: emailController,
                    decoration: myDecoration.copyWith(
                      labelText: "Email",
                      labelStyle: const TextStyle(
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
                        splashRadius: 1,
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: togglePasswordVisibility,
                        tooltip: _isPasswordVisible
                            ? 'Ocultar senha'
                            : 'Mostrar senha',
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),

                  const SizedBox(height: 8),

                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage()));
                          },
                          child: Semantics(
                            label: 'Esqueceu a senha',
                            child: Text(
                              'Esqueci minha senha',
                              style: TextStyle(
                                color: Colors.deepPurple[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    onTap: loginUser,
                    buttonText: "Entrar",
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não possui conta?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage())),
                        child: Semantics(
                          label: 'Registre-se agora',
                          child: const Text(
                            'Cadastre-se!',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
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
