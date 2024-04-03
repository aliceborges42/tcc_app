import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final String labelText;
  final ValueChanged<DateTime?> onChanged;

  const CustomDatePicker({
    Key? key,
    required this.initialDate,
    required this.labelText,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.labelText),
      subtitle: Text(
        _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate)
            : 'Selecione a data',
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.initialDate ?? DateTime.now(),
          firstDate: DateTime(2015, 8),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && pickedDate != _selectedDate) {
          setState(() {
            _selectedDate = pickedDate;
          });
          widget.onChanged(pickedDate);
        }
      },
    );
  }
}
