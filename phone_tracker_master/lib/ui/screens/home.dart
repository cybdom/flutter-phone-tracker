import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phone_tracker/models/log_model.dart';
import 'package:phone_tracker/services/auth.dart';
import 'package:phone_tracker/services/log_api.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _myController = ScrollController(
      initialScrollOffset: 0.0,
    );
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
          )
        ],
      ),
      body: StreamBuilder<List<LogModel>>(
        stream: LogApi().getLocation(
            Provider.of<AuthService>(context, listen: false).token),
        builder: (context, snapshot) {
          switch (snapshot.hasData) {
            case true:
              return Column(
                children: <Widget>[
                  Flexible(
                    child: MyGoogleMap(
                      currentLocation: snapshot.data.last,
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      controller: _myController,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(
                          "Latitude: ${snapshot.data[i].latitude}",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Longitude: ${snapshot.data[i].longitude}",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}

class MyGoogleMap extends StatefulWidget {
  final LogModel currentLocation;

  const MyGoogleMap({Key key, @required this.currentLocation})
      : super(key: key);

  @override
  _MyGoogleMapState createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  @override
  Widget build(BuildContext context) {
    final LogModel _currentPosition = widget.currentLocation;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      ),
      markers: [
        Marker(
          markerId: MarkerId("UserPosition"),
          position:
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
          infoWindow: InfoWindow(snippet: _currentPosition.timestamp),
        )
      ].toSet(),
    );
  }
}
