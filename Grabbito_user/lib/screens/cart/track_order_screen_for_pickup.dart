import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/booking_order_for_package.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/screens/home/home_screen.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

import 'order_detail_screen.dart';

class TrackOrderScreenForPickup extends StatefulWidget {
  final SendPackageData bookOrderPassingData;
  TrackOrderScreenForPickup({
    required this.bookOrderPassingData,
  });

  @override
  _TrackOrderScreenForPickupState createState() =>
      _TrackOrderScreenForPickupState();
}

class _TrackOrderScreenForPickupState extends State<TrackOrderScreenForPickup> {
// List of coordinates to join
  List<LatLng> polylineCoordinates = [];
// Map storing polyline created by connecting two points
  Map<PolylineId, Polyline> polyLines = {};
  late PolylinePoints polylinePoints;
  Completer<GoogleMapController> googleMapController = Completer();
  late CameraPosition _kGooglePlex;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String driverNumber = '';
  String driverName = '';
  String driverImage = '';

  Timer? timer;
  int counter = 0;

  double? _positionOnMapLat = 0,
      _positionOnMapLong = 0,
      _shopLatitude = 0,
      _shopLongitude = 0,
      _driverLatitude = 0,
      _driverLongitude = 0,
      _userLatitude = 0,
      _userLongitude = 0;

  bool isDriverAvailable = false;
  bool foodIsPrepared = false;
  bool readyForPickup = false;
  bool successfullyDelivered = false;

  @override
  void initState() {
    super.initState();
    //TODO:change to live
    //set latitudes driver, shop, user
    if (widget.bookOrderPassingData.pickLang!.isNotEmpty &&
        widget.bookOrderPassingData.pickLang!.isNotEmpty) {
      _userLatitude = double.parse(widget.bookOrderPassingData.pickLat!);
      _userLongitude = double.parse(widget.bookOrderPassingData.pickLang!);
    }
    if (widget.bookOrderPassingData.shop!.lat != null &&
        widget.bookOrderPassingData.shop!.lang != null) {
      _shopLatitude =
          double.parse(widget.bookOrderPassingData.shop!.lat.toString());
      _shopLongitude =
          double.parse(widget.bookOrderPassingData.shop!.lang.toString());
    }
    if (widget.bookOrderPassingData.driver != null) {
      isDriverAvailable = true;
    }
    if (isDriverAvailable) {
      _driverLatitude = double.parse(widget.bookOrderPassingData.driver!.lat!);
      _driverLongitude =
          double.parse(widget.bookOrderPassingData.driver!.lang!);
      driverNumber = widget.bookOrderPassingData.driver!.phoneCode! +
          widget.bookOrderPassingData.driver!.phone!;
      driverName = widget.bookOrderPassingData.driver!.name!;
      driverImage = widget.bookOrderPassingData.driver!.fullImage!;
    }
    _positionOnMapLat = _userLatitude;
    _positionOnMapLong = _userLongitude;

    //change
    _kGooglePlex = CameraPosition(
      target: LatLng(_positionOnMapLat!, _positionOnMapLong!),
      zoom: 14.4746,
    );

    //change
    _add(_positionOnMapLat, _positionOnMapLong, 'assets/images/source.svg',
        MarkerId('user'), 'user');
    _add(_shopLatitude, _shopLongitude, 'assets/images/destination.svg',
        MarkerId('shop'), 'shop');
    if (isDriverAvailable) {
      _add(_driverLatitude, _driverLongitude, 'assets/images/source.svg',
          MarkerId('driver'), 'driver');
    }
    _createPolylines(
        _userLatitude!, _userLongitude!, _shopLatitude!, _shopLongitude!);

    if (mounted) {
      timer = Timer.periodic(
          Duration(
              seconds: int.parse(
                  PreferenceUtils.getString(PreferenceNames.autoRefresh))),
          (t) {
        if (mounted) {
          setState(() {
            counter++;
            print("counter++:$counter");
            driverTrackOrder();
          });
        } else {
          counter++;
          print("counter++:$counter");
          driverTrackOrder();
        }
      });
    } else {
      timer = Timer.periodic(
          Duration(
              seconds: int.parse(
                  PreferenceUtils.getString(PreferenceNames.autoRefresh))),
          (t) {
        setState(() {
          counter++;
          print("counter++:$counter");
          driverTrackOrder();
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        orientation: Orientation.portrait);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorWhite,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(0),
              ),
            ),
          ),
          title: Text(
            getTranslated(context, trackOrder).toString(),
            style: TextStyle(
                fontFamily: 'Grold Black',
                color: colorBlack,
                fontSize: 18),
          ),
          actions: [
            Center(
                widthFactor: 1.2,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(
                          singleOrderId: widget.bookOrderPassingData.id!,
                          whichOrder: 'pickupOrder',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    getTranslated(context, viewDetails).toString(),
                    style: TextStyle(
                        color: colorBlue,
                        fontFamily: groldReg,
                        fontSize: 14),
                  ),
                )),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polyLines.values),
                onMapCreated: (GoogleMapController controller) {
                  googleMapController.complete(controller);
                },
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                color: colorWhite,
                child: _buildTimeline(),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTimeline() {
    return Container(
      color: Colors.white,
      height: SizeConfig.screenHeight! / 2,
      width: SizeConfig.screenWidth,
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          //first
          SizedBox(
            height: ScreenUtil().setHeight(18.0),
            child: TimelineTile(
              axis: TimelineAxis.vertical,
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              afterLineStyle: LineStyle(
                color: foodIsPrepared ? colorBlack : colorDivider,
                thickness: 2,
              ),
              beforeLineStyle: LineStyle(
                color: colorDivider,
                thickness: 2,
              ),
              indicatorStyle: IndicatorStyle(
                color: colorBlack,
                width: 12.0,
                height: 12.0,
              ),
              isFirst: true,
              endChild: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      getTranslated(context, foodPrepared).toString(),
                      style: TextStyle(
                        color: colorBlack,
                        fontFamily: groldBold,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //second
          SizedBox(
            height: ScreenUtil().setHeight(180),
            child: TimelineTile(
              axis: TimelineAxis.vertical,
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              afterLineStyle: LineStyle(
                color: readyForPickup ? colorBlack : colorDivider,
                thickness: 2,
              ),
              beforeLineStyle: LineStyle(
                color: foodIsPrepared ? colorBlack : colorDivider,
                thickness: 2,
              ),
              indicatorStyle: IndicatorStyle(
                color: readyForPickup ? colorBlack : colorDivider,
                width: 12.0,
                height: 12.0,
              ),
              isFirst: false,
              endChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      Text(
                        getTranslated(context, orderPickup).toString(),
                        style: TextStyle(
                          color: colorBlack,
                          fontFamily: groldBold,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isDriverAvailable,
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  child: CachedNetworkImage(
                                    alignment: Alignment.center,
                                    fit: BoxFit.fill,
                                    imageUrl: driverImage,
                                    height: ScreenUtil().setHeight(50),
                                    width: ScreenUtil().setWidth(50),
                                    placeholder: (context, url) =>
                                        SpinKitFadingCircle(color: colorRed),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            "assets/images/no_image.png"),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: groldBold,
                                      ),
                                    ),
                                    Text(
                                      driverNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: groldReg,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _makePhoneCall('tel:$driverNumber');
                              },
                              icon: CircleAvatar(
                                radius: 20,
                                backgroundColor: colorRed,
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //third
          SizedBox(
            height: ScreenUtil().setHeight(18.0),
            child: TimelineTile(
              axis: TimelineAxis.vertical,
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              afterLineStyle: LineStyle(
                color: successfullyDelivered ? colorBlack : colorDivider,
                thickness: 2,
              ),
              beforeLineStyle: LineStyle(
                color: successfullyDelivered ? colorBlack : colorDivider,
                thickness: 2,
              ),
              indicatorStyle: IndicatorStyle(
                color: successfullyDelivered ? colorBlack : colorDivider,
                width: 12.0,
                height: 12.0,
              ),
              isLast: true,
              endChild: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      getTranslated(context, successfullyDeliveredName)
                          .toString(),
                      style: TextStyle(
                        color: colorBlack,
                        fontFamily: groldBold,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      CommonFunction.toastMessage("Something went Wrong");
      throw 'Could not launch $url';
    }
  }

  void _add(lat, long, icon, markerId, String who) async {
    late BitmapDescriptor bitmapDescriptor;
    bitmapDescriptor = await _bitmapDescriptorFromSvgAsset(context, '$icon');
    setState(() {});
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        long,
      ),
      icon: bitmapDescriptor,
      infoWindow: who == 'user'
          ? InfoWindow(
              title: "User",
              snippet:
                  PreferenceUtils.getString(PreferenceNames.loggedInUserName))
          : who == 'driver'
              ? InfoWindow(title: "Driver", snippet: driverName)
              : InfoWindow(
                  title: "Shop",
                  snippet: "${widget.bookOrderPassingData.shop!.name}"),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  // Create the polylines for showing the route between two places
  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width =
        32 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 32 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    late PolylineResult result;
    if (Platform.isAndroid) {
      result = await polylinePoints.getRouteBetweenCoordinates(
        androidKey, // Google Maps API Key
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: TravelMode.driving,
      );
    } else {
      result = await polylinePoints.getRouteBetweenCoordinates(
        iosKey, // Google Maps API Key
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: TravelMode.driving,
      );
    }
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: colorBlack,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polyLines[id] = polyline;
    setState(() {});
  }

  Future<BaseModel<String>> driverTrackOrder() async {
    String response;
    try {
      response = await ApiServices(ApiHeader().dioData())
          .driverTrackOrder(widget.bookOrderPassingData.id, "pickup");

      final responseBody = json.decode(response);
      bool? success = responseBody['success'];
      if (success == true &&
          responseBody['data']['order_status'] != 'Pending') {
        setState(() {
          isDriverAvailable = true;
          _driverLatitude =
              double.parse(responseBody['data']['lat'].toString());
          _driverLongitude =
              double.parse(responseBody['data']['lang'].toString());
          setMarker(_driverLatitude!, _driverLongitude!);
          if (responseBody['data']['order_status'] == 'Pending' ||
              responseBody['data']['order_status'] == 'Approve' ||
              responseBody['data']['order_status'] == 'Accept' ||
              responseBody['data']['order_status'] == 'Reject' ||
              responseBody['data']['order_status'] == 'Cancel') {
            foodIsPrepared = true;
            readyForPickup = false;
            successfullyDelivered = false;
          } else if (responseBody['data']['order_status'] ==
                  'Driver PickedUp Item' ||
              responseBody['data']['order_status'] == 'Preparing Item' ||
              responseBody['data']['order_status'] == 'On The Way') {
            foodIsPrepared = true;
            readyForPickup = true;
            successfullyDelivered = false;
          } else {
            foodIsPrepared = true;
            readyForPickup = true;
            successfullyDelivered = true;
          }

          if (driverName.isEmpty) {
            driverName = responseBody['data']['name'];
            driverNumber = responseBody['data']['phone_code'] +
                responseBody['data']['phone'];
            driverImage = responseBody['data']['fullImage'];
          }
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  setMarker(double lat, double lang) async {
    print("New counter: $lat , $lang");

    BitmapDescriptor bitmapDescriptorDriver =
        await _bitmapDescriptorFromSvgAsset(
            context, 'assets/images/source.svg');

    final marker = markers.values
        .toList()
        .firstWhere((item) => item.markerId == MarkerId('driver'));

    Marker _marker = Marker(
      markerId: marker.markerId,
      position: LatLng(lat, lang),
      icon: bitmapDescriptorDriver,
    );

    setState(() {
      //the marker is identified by the markerId and not with the index of the list
      markers[MarkerId('driver')] = _marker;
    });
  }

  Future<bool> _onWillPop() async {
    return (await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(0),
          ),
        )) ??
        false;
  }
}
