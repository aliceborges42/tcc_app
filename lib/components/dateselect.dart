import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectionButton extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime?) onDateSelected;

  const DateSelectionButton({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2015, 8),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
      ),
      child: Text(
        selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
            : 'Selecionar Data',
      ),
    );
  }
}
