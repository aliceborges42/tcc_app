import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/components/my_textfield.dart';
import 'package:tcc_app/resources/auth_methods.dart';

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
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
          SnackBar(
            content: Text('Password reset successful!'),
            duration: Duration(seconds: 3),
          ),
        );
        // Redirecionando para a página de login após 3 segundos
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Passwords do not match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
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
        backgroundColor: Colors.deepPurple[200],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'Enter your email and we will send you a password reset link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            if (showCodeInput) ...[
              SizedBox(height: 10),
              MyTextField(
                controller: codeController,
                hintText: 'Code',
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: newPasswordController,
                hintText: 'New Password',
                obscureText: true,
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
            ],
            SizedBox(height: 10),
            MyButton(
              onTap: showCodeInput ? resetPasswordWithCode : resetPassword,
              buttonText: showCodeInput ? "Reset Password" : "Send Email",
              isLoading: isLoading,
            ),
            if (showCodeInput && canResendCode) ...[
              SizedBox(height: 10),
              Text(
                "Resend code in $resendTimer seconds",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              MyButton(
                onTap: resendCode,
                buttonText: "Resend Code",
                isLoading: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
