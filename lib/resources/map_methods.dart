import 'package:geocoding/geocoding.dart';

Future<String> getAddressByLatLon(double lat, double lng) async {
  List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
  var address = placemark.reversed.last;
  print("\n\nPLACEMARK: ${address}\n\n");
  //  placemark.map((e) => print("\n\nPLACEMARK MAP: ${e}\n\n"));
  return placemark[0].toString();
  // var output = 'No results found.';

  // placemarkFromCoordinates(lat, lng).then((placemarks) {
  //   if (placemarks.isNotEmpty) {
  //     output = placemarks[0].toString();
  //   }
  // });
  // return output;
}
