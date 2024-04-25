import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/utils/global_variable.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showCodeInput = false;
  bool canResendCode = false;
  int resendTimer = 0;
  late Timer timer;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    resendTimer = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          canResendCode = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    timer.cancel();
    super.dispose();
  }

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      await authMethods.forgotPassword(email: emailController.text.trim());
      setState(() {
        showCodeInput = true;
        isLoading = false;
      });
      startResendTimer();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> resetPasswordWithCode() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (newPasswordController.text == confirmPasswordController.text) {
        await authMethods.resetPassword(
            email: emailController.text.trim(),
            newPassword: newPasswordController.text,
            resetToken: codeController.text,
            passwordConfirmation: confirmPasswordController.text);
        setState(() {
          isLoading = false;
        });
        // Exibindo snackbar de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successful!'),
            duration: Duration(seconds: 3),
          ),
        );
        // Redirecionando para a página de login após 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Passwords do not match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> resendCode() async {
    setState(() {
      canResendCode = false;
    });
    await resetPassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Esqueci minha senha',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white,
          tooltip: 'Voltar',
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informe seu e-mail e te enviaremos um código para a redefinição da senha.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: myDecoration.copyWith(
                  labelText: "Email",
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                  ), // Atualizando o hintText com o texto fornecido
                ),
                obscureText: false,
              ),
              if (showCodeInput) ...[
                SizedBox(height: 15),
                TextField(
                  controller: codeController,
                  decoration: myDecoration.copyWith(
                    labelText: "Código",
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                    ), // Atualizando o hintText com o texto fornecido
                  ),
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  decoration: myDecoration.copyWith(
                    labelText: "Nova Senha",
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                    ), // Atualizando o hintText com o texto fornecido
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  decoration: myDecoration.copyWith(
                    labelText: "Confirme a Senha",
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                    ), // Atualizando o hintText com o texto fornecido
                  ),
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 25),
              MyButton(
                onTap: showCodeInput ? resetPasswordWithCode : resetPassword,
                buttonText: showCodeInput ? "Redefinir Senha" : "Enviar Email",
                isLoading: isLoading,
              ),
              if (showCodeInput && canResendCode) ...[
                const SizedBox(height: 10),
                Text(
                  "Reenviar código em $resendTimer segundos",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    elevation: 0,
                    backgroundColor:
                        Colors.grey[100], // Define a cor do texto como preto
                    side: const BorderSide(
                        color: Colors.black), // Adiciona uma borda preta
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5.0), // Define o raio do canto do botão
                    ),
                  ),
                  onPressed: resendCode,
                  child: const Text(
                    "Reenviar Código",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
