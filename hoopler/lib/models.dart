import 'dart:ffi';

import 'dart:math';

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

class Court {
  final int id;
  final String name;
  final bool indoor;
  final int hoops;
  final String photo;
  final int current_players;
  final double lat;
  final double lon;

  const Court({
    required this.id,
    required this.name,
    required this.indoor,
    required this.hoops,
    required this.photo,
    required this.current_players,
    required this.lat,
    required this.lon,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      name: json['name'],
      indoor: json['indoor'],
      hoops: json['hoops'],
      photo: json['photo'],
      current_players: json['current_players'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
