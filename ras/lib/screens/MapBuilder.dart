import 'dart:async';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class MapBuilder extends StatefulWidget {
  const MapBuilder({Key? key}) : super(key: key);

  @override
  _MapBuilderState createState() => _MapBuilderState();
}

class _MapBuilderState extends State<MapBuilder> {
  Completer<GoogleMapController> _controller = Completer();

  static CameraPosition _initPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15,
  );

  static int shapeType = 0;
  // 0 = none; 1 = placemark; 2 = polygon ...

  static bool editing = false;

  Set<Marker> _markers = Set<Marker>();
  List<LatLng> _polygonVertex = [];
  Set<Polygon> _polygons = new Set();

  var uuid = Uuid();
  String currentMarkerId = '';
  String currentVertexId = '';

  _setUserLocation() async {
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      _determinePosition();
    } else {
      _showAlertDialog(
          'Ops!', 'You need to device location to use this feature');
    }
  }

  Future<LatLng> _determinePosition() async {
    Position position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    return LatLng(position.latitude, position.longitude);
  }

  _showAlertDialog(String title, String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$title'),
            content: Text('$msg'),
            actions: <Widget>[
              OutlinedButton(
                child: Text("CLOSE"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  primary: Colors.blue,
                  side: BorderSide(color: Colors.blue, width: 1),
                ),
              ),
            ],
          );
        });
  }

  _handleTap(LatLng value) {
    switch (shapeType) {
      case 1:
        // new marker
        var id = uuid.v1();
        Marker m = Marker(
            markerId: MarkerId(id),
            position: value,
            draggable: true,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
              setState(() {
                editing = true;
                currentMarkerId = id;
                shapeType = 1;
              });
            });
        setState(() {
          _markers.add(m);
        });
        break;
      case 2:
        // add vertex
        var id = uuid.v1();
        Marker vertex = Marker(
            markerId: MarkerId(id),
            position: value,
            draggable: true,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueYellow),
            onTap: () {
              currentVertexId = id;
              editing = true;
              shapeType = 2;
            },
            onDragEnd: (newValue) {});
        setState(() {
          _polygonVertex.add(vertex.position);
          _markers.add(vertex);
          if (_polygonVertex.length >= 3) _placePolygon();
        });
        break;
      default:
    }
  }

  _removeSeedMarker() {
    setState(() {
      _markers.removeWhere(
          (element) => element.markerId == MarkerId(currentMarkerId));
    });
  }

  _placeSeedInMyPosition() async {
    LatLng position = await _determinePosition();
    _handleTap(position);
  }

  _placePolygon() {
    setState(() {
      _polygons.add(Polygon(
        polygonId: PolygonId('area'),
        points: _polygonVertex,
        strokeColor: Colors.yellow,
        strokeWidth: 1,
        fillColor: Colors.yellow.withOpacity(0.15),
      ));
    });
  }

  _removePolygon() {
    _polygons = Set();
    _polygonVertex.forEach((vertex) {
      _markers.removeWhere((element) => element.position == vertex );
    });
    _polygonVertex = [];
  }

  _removeElement() {
    switch (shapeType) {
      case 1:
        _removeSeedMarker();
        break;
      case 2:
        _removePolygon();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: _initPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _handleTap,
            markers: _markers,
            polygons: _polygons,
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                  child: FloatingActionButton(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                editing
                    ? Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, right: 10),
                            child: FloatingActionButton(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.delete),
                                onPressed: () {
                                  // delete shape
                                  _removeElement();
                                  setState(() {
                                    editing = false;
                                    shapeType = 0;
                                  });
                                }),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, right: 10),
                            child: FloatingActionButton(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.check),
                                onPressed: () {
                                  // finished editing shape
                                  setState(() {
                                    editing = false;
                                    shapeType = 0;
                                  });
                                }),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: FloatingActionButton(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.place),
                                onPressed: () {
                                  setState(() {
                                    // Shape now is Placemark
                                    shapeType = 1;
                                    editing = true;
                                  });
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: FloatingActionButton(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.place_outlined),
                                onPressed: () {
                                  setState(() {
                                    shapeType = 1;
                                    _placeSeedInMyPosition();
                                  });
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: FloatingActionButton(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.crop_square),
                                onPressed: () {
                                  setState(() {
                                    shapeType = 2;
                                    editing = true;
                                  });
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 90.0),
                            child: FloatingActionButton(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.my_location_rounded),
                                onPressed: () {
                                  _setUserLocation();
                                }),
                          ),
                        ],
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
