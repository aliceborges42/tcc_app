import 'package:flutter/material.dart';
import 'package:tcc_app/utils/colors.dart';

const webScreenSize = 600;

final myDecoration = InputDecoration(
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: grayBlack),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: lightBlack),
  ),
  fillColor: white,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey[500]),
);

InputDecoration myDecorationdois({required String labelText}) =>
    InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.grey),
      errorStyle: TextStyle(color: Colors.red), // Estilo do texto de erro
      errorBorder: OutlineInputBorder(
        // Borda quando em estado de erro
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        // Borda em estado normal
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        // Borda quando o campo está focado
        borderSide: BorderSide(color: lightBlack),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        // Borda padrão
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
    );
