import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ridemate/Providers/bookingprovider.dart';
import 'package:ridemate/Providers/completeprofileprovider.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/Providers/driverrideprovider.dart';
import 'package:ridemate/Providers/googleauthprovider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/joinviaphoneprovider.dart';
import 'package:ridemate/Providers/mapprovider.dart';
import 'package:ridemate/Providers/onboardingprovider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/Providers/verifyotpprovider.dart';
import '../Providers/useraddressprovider.dart';

List<SingleChildWidget> providerlist = [
  ChangeNotifierProvider(
    create: (context) => Onboardingprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Homeprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Joinviaphoneprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Verifyotpprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Completeprofileprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Googleloginprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Userdataprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Pickupaddress(),
  ),
  ChangeNotifierProvider(
    create: (context) => Destinationaddress(),
  ),
  ChangeNotifierProvider(
    create: (context) => Mapprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Motodrivercnic(),
  ),
  ChangeNotifierProvider(
    create: (context) => Motodriverlicence(),
  ),
  ChangeNotifierProvider(
    create: (context) => Cardrivercnic(),
  ),
  ChangeNotifierProvider(
    create: (context) => Cardriverlicence(),
  ),
  ChangeNotifierProvider(
    create: (context) => Motobasicinfo(),
  ),
  ChangeNotifierProvider(
    create: (context) => Carbasicinfo(),
  ),
  ChangeNotifierProvider(
    create: (context) => Motoselfieid(),
  ),
  ChangeNotifierProvider(
    create: (context) => Carselfieid(),
  ),
  ChangeNotifierProvider(
    create: (context) => Motovehiclephoto(),
  ),
  ChangeNotifierProvider(
    create: (context) => Carvehiclephoto(),
  ),
  ChangeNotifierProvider(
    create: (context) => Carreg(),
  ),
  ChangeNotifierProvider(
    create: (context) => Motoreg(),
  ),
  ChangeNotifierProvider(
    create: (context) => Transportnameprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => Bookingprovider(),
  ),
  ChangeNotifierProvider(
    create: (context) => DriverRideProivder(),
  )
];
