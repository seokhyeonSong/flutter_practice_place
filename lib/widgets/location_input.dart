import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/location_helper.dart';
import '../models/place.dart';
import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;
  const LocationInput(this.onSelectPlace, {Key? key}) : super(key: key);

  @override
  State<LocationInput> createState() => LocationInputState();
}

class LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;
  PlaceLocation? _previewPlaceLocation;

  void _showPreview(double? lat, double? lng) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat ?? 37.5642135,
      longitude: lng ?? 127.0016985,
    );

    setState(() {
      _previewImageUrl = staticMapImageUrl;
      _previewPlaceLocation = PlaceLocation(
        latitude: lat ?? 37.5642135,
        longitude: lng ?? 127.0016985,
      );
    });

    widget.onSelectPlace(
      lat ?? 37.5642135,
      lng ?? 127.0016985,
    );
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final locData = await Location().getLocation();
      _showPreview(locData.latitude, locData.longitude);
    } catch (e) {
      return;
    }
  }

  Future<void> _selectOnMap() async {
    final selectedlocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        maintainState: false,
        builder: (ctx) => MapScreen(
          initialLocation: _previewPlaceLocation == null
              ? const PlaceLocation(latitude: 34.9669, longitude: 135.7748)
              : PlaceLocation(
                  latitude: _previewPlaceLocation!.latitude,
                  longitude: _previewPlaceLocation!.longitude,
                ),
          isSelecting: true,
        ),
      ),
    );

    if (selectedlocation == null) {
      return;
    }

    _showPreview(selectedlocation.latitude, selectedlocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 170,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: _previewImageUrl == null
            ? const Text(
                'No Location Chosen',
                textAlign: TextAlign.center,
              )
            : Image.network(
                _previewImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('Current Location'),
            textColor: Theme.of(context).primaryColor,
            onPressed: _getCurrentUserLocation,
          ),
          FlatButton.icon(
            icon: const Icon(Icons.map),
            label: const Text('Select on Map'),
            textColor: Theme.of(context).primaryColor,
            onPressed: _selectOnMap,
          )
        ],
      )
    ]);
  }
}
