import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconly/iconly.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/support_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/utilities/size_config.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool _loading = false;
  List<SupportData> supportDataList = [];

  @override
  void initState() {
    super.initState();
    supportApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, support).toString(),
          style: TextStyle(
            fontWeight: FontWeight.w400,
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent,
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: ListView.builder(
            itemCount: supportDataList.length,
            padding: EdgeInsets.only(
              bottom: 20,
            ),
            itemBuilder: (context, index) {
              return SizedBox(
                width: SizeConfig.screenWidth,
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  // childrenPadding: EdgeInsets.zero,
                  title: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                              fontFamily: groldBold,
                              color: colorBlack,
                              fontSize: 14),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            supportDataList[index].question.toString(),
                            style: TextStyle(
                                fontFamily: groldBold,
                                color: colorBlack,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      width: SizeConfig.screenWidth,
                      padding:
                          EdgeInsets.only(left: 22),
                      child: Text(
                        supportDataList[index].answer.toString(),
                        style: TextStyle(
                            fontFamily: groldReg,
                            color: colorBlack,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<BaseModel<SupportModel>> supportApi() async {
    SupportModel response;
    try {
      setState(() {
        _loading = true;
      });
      // String deviceToken = PreferenceUtils.getString(PreferenceNames.device_token);
      response = await ApiServices(ApiHeader().dioData()).support();

      if (response.success == true) {
        supportDataList.addAll(response.data!);
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
