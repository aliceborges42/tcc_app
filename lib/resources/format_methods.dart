import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<String> formatDate(DateTime dataOcorrido) async {
  await initializeDateFormatting('pt_BR', null);

  String formattedDate = DateFormat.yMMMMd('pt_BR').format(dataOcorrido);

  return formattedDate;
}

String formatHour(DateTime horaOcorrido) {
  String formattedTime = DateFormat.Hm().format(horaOcorrido);

  return formattedTime;
}
