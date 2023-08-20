import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import "models.dart";

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var courts;
  final Set<Marker> markers = new Set();
  @override
  void initState() {
    fetchCourts();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  void fetchCourts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/api/courts'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      print(l);
      setState(() {
        courts = List<Court>.from(l.map((model) => Court.fromJson(model)));
      });
      for (var i in courts) {
        markers.add(Marker(
          //add first marker
          markerId: MarkerId(i.name.toString()),
          position: LatLng(i.lat, i.lon), //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: i.name,
            snippet: "Active: " + i.current_players.toString(),
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      }
      print(courts);
    } else {
      throw Exception('Failed to load courts');
    }
  }

  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(52.237049, 21.017532);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              getUserCurrentLocation().then((value) async {
                print(value.latitude.toString() +
                    " " +
                    value.longitude.toString());

                // marker added for current users location
                markers.add(Marker(
                  markerId: MarkerId("2"),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: InfoWindow(
                    title: 'My Current Location',
                  ),
                ));

                // specified current users location
                CameraPosition cameraPosition = new CameraPosition(
                  target: LatLng(value.latitude, value.longitude),
                  zoom: 14,
                );

                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition));
                setState(() {});
              });
            },
            child: Icon(Icons.local_activity),
          ),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(239, 236, 104, 27),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.map)),
                Tab(icon: Icon(Icons.list)),
              ],
            ),
            title: const Text('HOOPLE'),
          ),
          body: TabBarView(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _center, zoom: 10),
                markers: markers,
              ),
              ListView.builder(
                  itemCount: courts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(courts[index].name),
                        subtitle: Text("Active Players: " +
                            courts[index].current_players.toString()));
                  })
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       body: GoogleMap(
  //         onMapCreated: _onMapCreated,
  //         initialCameraPosition: CameraPosition(
  //           target: _center,
  //           zoom: 11.0,
  //         ),
  //         markers: markers,
  //       ));
  // }
}
