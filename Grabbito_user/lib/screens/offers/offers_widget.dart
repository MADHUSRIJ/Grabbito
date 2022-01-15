import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/homepage/offers_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:iconly/iconly.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  TextEditingController searchController = TextEditingController();
  bool isSearched = false;
  List<OfferModelData> offers = [];
  Future<BaseModel<OffersModel>>? offersData;

  @override
  void initState() {
    super.initState();
    offersData = offersAtRestaurantApi();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(IconlyBold.discount,size: 24.0,color: colorBlack,),
        ),
        backgroundColor: colorWhite,
        title: Text(
          getTranslated(context, offersTitle).toString(),
          style: TextStyle(
              fontFamily: groldReg, color: colorBlack, fontSize: 20,fontWeight: FontWeight.w400),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: _buildOffersWidget(),
      ),
    );
  }

  _buildOffersWidget() => FutureBuilder(
        future: offersData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SpinKitFadingCircle(color: colorRed);
          } else {
            return offers.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      itemCount: offers.length,
                      shrinkWrap: true,
                      primary: false,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return Container(
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(20),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: SizeConfig.screenWidth! / 1.7,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: PreferenceUtils.getString(
                                                PreferenceNames
                                                    .currentLanguageCode) ==
                                            'ar'
                                        ? AssetImage(
                                            'assets/images/offer_flipped.png')
                                        : AssetImage('assets/images/offer.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offers[index].description.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: groldReg,
                                          color: colorBlack),
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.7,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color:
                                                    Colors.grey.withAlpha(40),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                text:
                                                    '${getTranslated(context, useCodeText).toString()} ',
                                                style: TextStyle(
                                                  color: colorBlack,
                                                  fontSize: 12,
                                                  fontFamily: groldReg,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        '${offers[index].code}',
                                                    style: TextStyle(
                                                        color: colorBlack,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            groldReg),
                                                    //Use Code GRAB50
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                      text:
                                                          "${offers[index].code}"))
                                                  .then((_) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                    getTranslated(context,
                                                            couponCopied)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            groldBold),
                                                  ),
                                                  backgroundColor: colorBlue,
                                                ));
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  getTranslated(
                                                          context, copyText)
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: colorBlue,
                                                    fontSize: 14,
                                                    fontFamily: groldReg,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.copy,
                                                  size: 20,
                                                  color: colorBlue,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3.34,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      getTranslated(context, getText)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: groldReg,
                                        color: colorBlack,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      () {
                                        if (offers[index].type == "amount") {
                                          return '${PreferenceUtils.getString(PreferenceNames.currencyCodeSetting)} ${offers[index].discount}';
                                        } else {
                                          return '${offers[index].discount}%';
                                        }
                                      }(),
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontFamily: groldReg,
                                        color: colorBlack,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'off',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: groldReg,
                                        color: colorBlack,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/no_image.png"),
                        Text(
                          getTranslated(context, noDataDesc).toString(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: groldReg,
                            color: colorBlack,
                          ),
                        ),
                      ],
                    ),
                  );
          }
        },
      );

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use refreshFailed()
    if (mounted) {
      setState(() {
        offersAtRestaurantApi();
      });
    }
  }

  Future<BaseModel<OffersModel>> offersAtRestaurantApi() async {
    OffersModel response;
    try {
      response = await ApiServices(ApiHeader().dioData()).offers();

      offers.clear();
      if (response.success == true) {
        if (response.data!.isNotEmpty) {
          offers.addAll(response.data!);
        }
      }

      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
