import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/repository/models/on_boarding_response.dart';
import 'package:grabbito/screens/on_board/comp/on_board_page.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

int currentPage = 0;
List<OnBoardResponse> pageList = [];
List<Widget> onBoardItems = [];
PageController _controller = PageController(initialPage: 0, keepPage: false);

class OnBoardScreen extends StatefulWidget {
  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pageList = [
      OnBoardResponse(
        "assets/images/onboard1.png",
      ),
    ];
    for (var item in pageList) {
      //adding onboard pages
      onBoardItems.add(OnBoardPage(
        pageItem: item,
      ));
    }
    return Scaffold(
      backgroundColor: colorWhite,
      body: SizedBox(
        height: double.maxFinite,
        child: Stack(
          children: <Widget>[
            PageView(
              physics: pageList.length < 2 ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
              controller: _controller,
              onPageChanged: (value) {
                setState(() {
                  currentPage = value;
                  // currentPage >= pageList.length
                  //     ? Navigator.pushNamed(context, loginRoute)
                  //     : _controller.animateToPage(currentPage,
                  //         duration: Duration(milliseconds: 300),
                  //         curve: Curves.linear);
                  PreferenceUtils.setBool(PreferenceNames.onBoardDone, true);
                  PreferenceUtils.setBool(
                      PreferenceNames.onBoardDoneFirst, true);
                });
              },
              children: onBoardItems,
            ),
          ],
        ),
      ),
    );
  }
}
