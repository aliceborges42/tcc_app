import 'package:flutter/material.dart';
import 'package:tcc_app/utils/colors.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText; // Add this line
  final bool isLoading;
  const MyButton(
      {super.key,
      required this.onTap,
      required this.buttonText,
      required this.isLoading}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        // margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.deepPurple[600],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: !isLoading
              ? Text(
                  buttonText, // Use the custom text here
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                )
              : SizedBox(
                  width: 21, // Largura do CircularProgressIndicator
                  height: 21, // Altura do CircularProgressIndicator
                  child: CircularProgressIndicator(
                    strokeWidth: 2, // Espessura da linha do progresso
                    color: Colors.white, // Cor do CircularProgressIndicator
                  ),
                ),
        ),
      ),
    );
  }
}
