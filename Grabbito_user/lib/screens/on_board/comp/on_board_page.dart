import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/repository/models/on_boarding_response.dart';
import 'package:grabbito/routes/route_names.dart';

class OnBoardPage extends StatefulWidget {
  final OnBoardResponse pageItem;

  OnBoardPage({required this.pageItem});

  @override
  _OnBoardPageState createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 343,
            width: 343,
            child: Image.asset(
              widget.pageItem.image,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            height: 77,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Many needs. One app.\nJust Grabbito! ",
              style: TextStyle(
                  fontFamily: groldReg,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  color: Color(0xff2E2E33)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Food, groceries, essentials, packages, and more are delivered to your doorstep.",
              style: TextStyle(
                  fontFamily: groldReg,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xff54545A)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 28,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, loginRoute);
                    },
                    child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 16, right: 8),
                decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: colorOrange,
                      border: Border.all(width: 1, color: colorOrange)),
                height: 48,
                child: Text(
                    "Log in",
                    style: TextStyle(
                        fontFamily: groldReg,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: colorWhite),
                    textAlign: TextAlign.center,
                ),
              ),
                  )),
              Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, registerRoute);
                    },
                    child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 8, right: 16),
                height: 48,
                decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: colorWhite,
                      border: Border.all(width: 1, color: colorOrange)),
                child: Text("Sign up",style: TextStyle(
                      fontFamily: groldReg,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: colorOrange),
                    textAlign: TextAlign.center,),
              ),
                  )),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "By logging in or registering, you agree to our \n",
                style: TextStyle(
                    fontFamily: groldReg,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xffD4D6D9)),
                children: const [
                  TextSpan(
                    text: "Terms of Service ",
                    style: TextStyle(
                      color: colorBlack
                    )
                  ),
                  TextSpan(
                    text: "and "
                  ),
                  TextSpan(
                    text: "Privacy Policy.",
                      style: TextStyle(
                          color: colorBlack
                      )
                  )
                ]
              ),

            ),
          ),
        ],
      ),
    );
  }
}
