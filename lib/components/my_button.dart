import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText; // Add this line
  final bool isLoading;
  const MyButton({super.key, required this.onTap, required this.buttonText, required this.isLoading}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: !isLoading ? Text(
            buttonText, // Use the custom text here
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
          : const CircularProgressIndicator(
                          color: Colors.black,
                        ),
        ),
      ),
    );
  }
}
