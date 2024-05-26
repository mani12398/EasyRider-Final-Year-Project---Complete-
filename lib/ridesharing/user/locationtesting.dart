import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String mapApiKey =
    "AIzaSyDoCmnLSTMCBPnbqrG3_71ZztjLItFsnfk"; // Replace with your actual API key

class PlacePredModel {
  final String placeId;
  final String description;

  PlacePredModel({required this.placeId, required this.description});

  factory PlacePredModel.fromJson(Map<String, dynamic> json) {
    return PlacePredModel(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}

class GoogleMapSearchPlacesApi extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;

  const GoogleMapSearchPlacesApi({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _GoogleMapSearchPlacesApiState createState() =>
      _GoogleMapSearchPlacesApiState();
}

class _GoogleMapSearchPlacesApiState extends State<GoogleMapSearchPlacesApi> {
  final TextEditingController _controller = TextEditingController();
  final uuid = const Uuid();
  String _sessionToken = '';
  List<PlacePredModel> _placeList = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onChanged();
    });
  }

  _onChanged() {
    if (_sessionToken == '') {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  Future<void> getSuggestion(String input) async {
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseUrl?input=$input&key=$mapApiKey&sessiontoken=$_sessionToken&components=country:pk&components=locality:islamabad';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          setState(() {
            message = '';
            _placeList = (result['predictions'] as List)
                .map((prediction) => PlacePredModel.fromJson(prediction))
                .toList();
          });
        } else if (result['status'] == 'ZERO_RESULTS') {
          setState(() {
            message = 'Nothing found';
            _placeList = [];
          });
        }
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      //print(e);
    }
  }

  Future<void> getPlaceDetails(String placeId, String description) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseUrl?placeid=$placeId&key=$mapApiKey';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          final placeDetails = result['result'];
          final location = placeDetails['geometry']['location'];
          widget.onLocationSelected(
              description, location['lat'], location['lng']);
          Navigator.pop(context);
        } else {
          setState(() {
            message = 'Failed to fetch place details';
          });
        }
      } else {
        throw Exception('Failed to fetch place details');
      }
    } catch (e) {
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Search location', backgroundColor: Appcolors.primaryColor),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search your location here",
                focusColor: Colors.white,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixIcon: const Icon(Icons.map),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_placeList[index].description),
                  onTap: () async {
                    await getPlaceDetails(_placeList[index].placeId,
                        _placeList[index].description);
                  },
                );
              },
            ),
          ),
          if (message.isNotEmpty)
            Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
