import 'package:ridemate/models/nearbyavailabledrivers.dart';

class Geofireassistant {
  static List<Nearbyavailabledrivers> nearbyavailabledriverslist = [];
  static void removedriverfromlist(String key) {
    int index =
        nearbyavailabledriverslist.indexWhere((element) => element.key == key);
    nearbyavailabledriverslist.removeAt(index);
  }

  static void updatedriverlocation(Nearbyavailabledrivers driver) {
    int index = nearbyavailabledriverslist
        .indexWhere((element) => element.key == driver.key);
    nearbyavailabledriverslist[index].latitude = driver.latitude;
    nearbyavailabledriverslist[index].longitude = driver.longitude;
  }
}
