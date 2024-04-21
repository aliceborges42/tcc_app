import 'package:flutter/material.dart';
import 'package:tcc_app/pages/map_page.dart';
import 'package:tcc_app/utils/colors.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const MapSample(),
  const Text('notifications'),
];

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
