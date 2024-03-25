import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String label;
  const Tag({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
          color: Colors.red[300],
        ),
        child: Center(
          child: Text(label),
        ));
  }
}
