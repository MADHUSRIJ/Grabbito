import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/constant/common_validations.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

String _selectedCountryCode = '+94';
List<String> _countryCodes = ['+91', '+1', '*94'];

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  TextEditingController selectAddressController = TextEditingController();
  TextEditingController landMarkController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController addAddressController = TextEditingController();
  String selectedAddress = "";
  Completer<GoogleMapController> googleMapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late CameraPosition _kGooglePlex;
  late bool isEdit;
  List<String> listOfSaveAddress = [];
  late String selectedListOfSaveAddress;
  late int selectedIdOfAddress;
  bool _loading = false;
  late double editLat;
  late double editLong;

  @override
  void initState() {
    super.initState();
    if (PreferenceUtils.getBool(
            PreferenceNames.editLocationFromManageLocation) ==
        true) {
      isEdit = true;
    } else {
      isEdit = false;
    }

    if (isEdit == false) {
      //for map
      _kGooglePlex = CameraPosition(
        target: LatLng(
            PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation),
            PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)),
        zoom: 16.4746,
      );
      //marker
      _add(
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation),
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation),
          "assets/images/ic_map_pin.svg",
          MarkerId("searched"));
      selectedAddress =
          PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);

      //for data filling
      selectAddressController.text =
          PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);
      landMarkController.text =
          PreferenceUtils.getString(PreferenceNames.landMarkOfSetLocation);
      contactNumController.text =
          PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber);
      _selectedCountryCode = PreferenceUtils.getString(
          PreferenceNames.loggedInUserPhoneNumberCode);
      listOfSaveAddress.add(
          PreferenceUtils.getString(PreferenceNames.locationTypeOfSetLocation));
      selectedListOfSaveAddress =
          PreferenceUtils.getString(PreferenceNames.locationTypeOfSetLocation);
    } else if (PreferenceUtils.getString(
            PreferenceNames.checkManageLocationPath) ==
        "fromEditSelectLocation") {
      editLat = PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation);
      editLong = PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation);
      //for map
      _kGooglePlex = CameraPosition(
        target: LatLng(
            PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation),
            PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)),
        zoom: 16.4746,
      );
      //marker
      _add(
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation),
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation),
          "assets/images/ic_map_pin.svg",
          MarkerId("searched"));
      selectedAddress =
          PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);

      //for data filling
      selectAddressController.text =
          PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);
      landMarkController.text =
          PreferenceUtils.getString(PreferenceNames.landMarkOfSetLocation);
      contactNumController.text =
          PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber);
      _selectedCountryCode = PreferenceUtils.getString(
          PreferenceNames.loggedInUserPhoneNumberCode);
      listOfSaveAddress.add(
          PreferenceUtils.getString(PreferenceNames.locationTypeOfSetLocation));
      selectedListOfSaveAddress =
          PreferenceUtils.getString(PreferenceNames.locationTypeOfSetLocation);
      List<String> tempHoldData =
          PreferenceUtils.getStringList(PreferenceNames.editLocationData);
      selectedIdOfAddress = int.parse(tempHoldData[0]);
    } else {
      List<String> tempHoldData =
          PreferenceUtils.getStringList(PreferenceNames.editLocationData);
      editLat = double.parse(tempHoldData[3]);
      editLong = double.parse(tempHoldData[4]);

      _kGooglePlex = CameraPosition(
        target: LatLng(editLat, editLong),
        zoom: 16.4746,
      );

      //marker
      _add(editLat, editLong, "assets/images/ic_map_pin.svg",
          MarkerId("searched"));
      selectedAddress = tempHoldData[2];

      //for data filling
      selectAddressController.text = tempHoldData[2];
      landMarkController.text = tempHoldData[5];
      contactNumController.text =
          PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber);
      _selectedCountryCode = PreferenceUtils.getString(
          PreferenceNames.loggedInUserPhoneNumberCode);
      listOfSaveAddress.add(tempHoldData[6]);
      selectedListOfSaveAddress = tempHoldData[6];
      selectedIdOfAddress = int.parse(tempHoldData[0]);
    }
  }

  void _add(lat, long, icon, markerId) async {
    BitmapDescriptor bitmapDescriptor =
        await _bitmapDescriptorFromSvgAsset(context, '$icon');
    setState(() {});
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        long,
      ),
      icon: bitmapDescriptor,
      // icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var countryDropDown = SizedBox(
      width: 30,
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              iconSize: 0.0,
              value: _selectedCountryCode,
              items: _countryCodes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: groldReg,
                      color: colorBlack,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value.toString();
                });
              },
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1.5,
                  color: colorWidgetBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit == true
              ? getTranslated(context, changeLocation).toString()
              : getTranslated(context, setLocation).toString(),
          style: TextStyle(
              fontFamily: groldReg,
              fontWeight: FontWeight.w400,
              color: colorBlack,
              fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent.withOpacity(0.2),
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  markers: Set<Marker>.of(markers.values),
                  onMapCreated: (GoogleMapController controller) {
                    if (mounted) {
                      setState(() {
                        googleMapController.complete(controller);
                      });
                    } else {
                      googleMapController.complete(controller);
                    }
                  },
                ),
              ),
            ),
            Expanded(
                flex: 5,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20, top: 30),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 0.5, color: colorWidgetBorder)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, selectBuildingName)
                                        .toString(),
                                    style: TextStyle(
                                        fontFamily: groldReg,
                                        fontSize: 16),
                                  ),
                                  Visibility(
                                    visible: isEdit,
                                    child: TextButton.icon(
                                        onPressed: () {
                                          PreferenceUtils.setString(
                                              PreferenceNames
                                                  .checkManageLocationPath,
                                              'fromEditSelectLocation');
                                          Navigator.pushNamed(
                                              context, setLocationRoute);
                                        },
                                        icon: Icon(Icons.refresh),
                                        label: Text(
                                            getTranslated(context, research)
                                                .toString(),
                                            style: TextStyle(
                                                fontFamily: groldReg,
                                                fontSize: 16))),
                                  )
                                ],
                              ),
                              TextField(
                                controller: selectAddressController,
                                readOnly: true,
                                style: TextStyle(
                                    fontFamily: groldReg, fontSize: 16),
                                keyboardType: TextInputType.text,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      getTranslated(context, enterHereText)
                                          .toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 0.5, color: colorWidgetBorder)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, landmarkIfAny)
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: groldReg, fontSize: 16),
                              ),
                              TextField(
                                controller: landMarkController,
                                style: TextStyle(
                                    fontFamily: groldReg, fontSize: 16),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      getTranslated(context, enterYourLandMark)
                                          .toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 0.5, color: colorWidgetBorder)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, contactNumber)
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: 'Grold Regular',
                                    fontSize: 16),
                              ),
                              TextField(
                                controller: contactNumController,
                                style: TextStyle(
                                    fontFamily: 'Grold Regular',
                                    fontSize: 16),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      getTranslated(context, contactNumberHint)
                                          .toString(),
                                  prefixIcon: countryDropDown,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, saveAddress).toString(),
                                style: TextStyle(
                                    fontFamily: groldReg, fontSize: 16),
                              ),
                              SizedBox(width: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    // width: MediaQuery.of(context).size.width / 2,
                                    child: ListView.separated(
                                      itemCount: listOfSaveAddress.length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) =>
                                          SizedBox(width: 10),
                                      itemBuilder: (context, index) => InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedListOfSaveAddress =
                                                listOfSaveAddress[index];
                                          });
                                        },
                                        child: Chip(
                                          labelPadding: EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 1,
                                              bottom: 1),
                                          label: Text(
                                            listOfSaveAddress[index],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color:
                                                    selectedListOfSaveAddress ==
                                                            listOfSaveAddress[
                                                                index]
                                                        ? colorWhite
                                                        : colorDivider,
                                                fontSize: 16,
                                                fontFamily: groldReg),
                                          ),
                                          backgroundColor:
                                              selectedListOfSaveAddress ==
                                                      listOfSaveAddress[index]
                                                  ? colorBlack
                                                  : colorWhite,
                                          shape: StadiumBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color:
                                                  selectedListOfSaveAddress ==
                                                          listOfSaveAddress[
                                                              index]
                                                      ? colorBlack
                                                      : colorDivider,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      buildShowDialog(context);
                                    },
                                    icon: Icon(Icons.add,color: colorOrange,),
                                    label: Text(
                                      getTranslated(context, addButtonText)
                                          .toString(),
                                      style: TextStyle(
                                          color: colorDivider,
                                          fontSize: 16,
                                          fontFamily: groldReg),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: colorOrange,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 16,right: 16,bottom: 22),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Text(
            isEdit == true
                ? getTranslated(context, changeLocation).toString()
                : getTranslated(context, setLocation).toString(),
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Grold Bold'),
          ),
        ),
        onTap: () {
          if (isEdit) {
            updateLocation();
          } else {
            addAddress();
          }
        },
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getTranslated(context, addAddressName).toString()),
        content: TextFormField(
          controller: addAddressController,
          style: TextStyle(
              color: colorDivider, fontSize: 16, fontFamily: groldReg),
          validator: ValidationConstants.kValidateName,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: getTranslated(context, addAddressLabelHint).toString(),
          ),
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              listOfSaveAddress.add(addAddressController.text);
              selectedListOfSaveAddress = addAddressController.text;
              setState(() {});
              Navigator.pop(context);
              addAddressController.clear();
            },
            child: Text('Add'),
          )
        ],
      ),
    );
  }

  Future<BaseModel<String>> updateLocation() async {
    String response;
    try {
      setState(() {
        _loading = true;
      });

      Map<String, dynamic> bodyForApi = {
        'address': selectAddressController.text,
        'landmark': landMarkController.text,
        'location_type': selectedListOfSaveAddress,
        'lat': editLat.toString(),
        'lang': editLong.toString(),
      };

      response = await ApiServices(ApiHeader().dioData())
          .updateLocation(selectedIdOfAddress, bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        PreferenceUtils.setBool(
            PreferenceNames.editLocationFromManageLocation, false);
        PreferenceUtils.remove(PreferenceNames.editLocationData);
        Navigator.pushReplacementNamed(context, manageLocationRoute);
      } else {
        CommonFunction.toastMessage(body["msg"].toString());
      }

      setState(() {
        _loading = false;
      });
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<String>> addAddress() async {
    String response;
    try {
      setState(() {
        _loading = true;
      });
      String address = '',
          landmark = '',
          locationType = '',
          lat = "",
          long = "";
      assert(PreferenceUtils.getString(PreferenceNames.addressOfSetLocation)
              .isNotEmpty &&
          PreferenceUtils.getString(PreferenceNames.landMarkOfSetLocation)
              .isNotEmpty &&
          PreferenceUtils.getString(PreferenceNames.locationTypeOfSetLocation)
              .isNotEmpty &&
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation) > 0.0 &&
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation) > 0.0);
      address = PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);
      landmark =
          PreferenceUtils.getString(PreferenceNames.landMarkOfSetLocation);
      locationType = PreferenceUtils.getString(
                  PreferenceNames.locationTypeOfSetLocation) ==
              'N/A'
          ? "Home"
          : PreferenceUtils.getString(
              PreferenceNames.locationTypeOfSetLocation);
      lat = PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
          .toString();
      long = PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
          .toString();

      Map<String, dynamic> bodyForApi = {
        'address': address,
        'landmark': landmark,
        'location_type': locationType,
        'lat': lat,
        'lang': long,
      };

      response =
          await ApiServices(ApiHeader().dioData()).addLocation(bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        PreferenceUtils.setInt(
            PreferenceNames.idOfSetLocation, body['location']['id']);
        PreferenceUtils.remove(PreferenceNames.checkManageLocationPath);
        Navigator.pushReplacementNamed(context, manageLocationRoute);
      } else {
        CommonFunction.toastMessage(body["message"]);
      }

      setState(() {
        _loading = false;
      });
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
