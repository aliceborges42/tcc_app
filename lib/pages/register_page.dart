import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc_app/components/my_button.dart';
import 'package:tcc_app/components/my_textfield.dart';
import 'package:tcc_app/pages/home_page.dart';
import 'package:tcc_app/pages/login_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/utils/colors.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    cpfController.dispose();
    super.dispose();
  }

  void signUp() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    try {
      String res = await AuthMethods().signUpUser(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          cpf: cpfController.text);

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

  Future addUserDetails(String name, String email, String cpf) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'email': email,
      'cpf': cpf,
    });
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  // wrong email message popup
  void emailAlreadyExistsMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepPurple,
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
      backgroundColor: background,
      body: SafeArea(
        child: ListView(shrinkWrap: true, children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                const Text(
                  'Cadastro',
                  style: TextStyle(
                    color: white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // email textfield
                MyTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: cpfController,
                  hintText: 'CPF',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  onTap: signUp,
                  buttonText: "Sign up",
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já possui conta?',
                      style: TextStyle(color: lightGray),
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
                          color: white,
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
