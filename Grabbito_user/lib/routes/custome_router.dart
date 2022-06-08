import 'package:flutter/material.dart';
import 'package:grabbito/model/homepage/business_types_model.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/auth/add_new_pass_screen.dart';
import 'package:grabbito/screens/auth/forgot_screen.dart';
import 'package:grabbito/screens/auth/login_screen.dart';
import 'package:grabbito/screens/auth/otp_verification_screen.dart';
import 'package:grabbito/screens/auth/register_screen.dart';
import 'package:grabbito/screens/cart/cart_screen.dart';
import 'package:grabbito/screens/category/category.dart';
import 'package:grabbito/screens/cart/select_location_screen.dart';
import 'package:grabbito/screens/category_details/food/comp/search_food_widget.dart';
import 'package:grabbito/screens/category_details/food/food_shops.dart';
import 'package:grabbito/screens/home/home_screen.dart';
import 'package:grabbito/screens/on_board/on_board_screen.dart';
import 'package:grabbito/screens/set_location/set_location_screen.dart';
import 'package:grabbito/screens/settings/comp/about_screen.dart';
import 'package:grabbito/screens/settings/comp/change_lang_screen.dart';
import 'package:grabbito/screens/settings/comp/change_password_screen.dart';
import 'package:grabbito/screens/settings/comp/manage_location_screen.dart';
import 'package:grabbito/screens/settings/comp/notification_center_screen.dart';
import 'package:grabbito/screens/settings/comp/privacy_policy_screen.dart';
import 'package:grabbito/screens/settings/comp/support_screen.dart';
import 'package:grabbito/screens/settings/comp/terms_and_condition_screen.dart';
import 'package:grabbito/screens/settings/settings_screen.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/transition.dart';

class CustomRouter {
  static Route<dynamic> allRoutes(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case onBoardRoute:
        return MaterialPageRoute(
          builder: (_) => OnBoardScreen(),
        );
      case loginRoute:
        if (PreferenceUtils.getBool(PreferenceNames.checkLogin) == true) {
          return Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: HomeScreen(0));
        } else {
          return Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen());
        }
      case registerRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: RegisterScreen());
      case forgotPasswordRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ForgotPasswordScreen());
      case newPasswordRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: NewPasswordScreen());
      case otpVerificationRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OtpVerificationScreen());
      case homeRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: HomeScreen(0));
      case setLocationRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: SetLocationScreen());
      case settingsRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: SettingsScreen());
      case changePasswordRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ChangePasswordScreen());
      case changeLanguageRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ChangeLanguageScreen());
      case manageLocationRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ManageLocationScreen());
      case notificationCenterRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: NotificationCenterScreen());
      case supportRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: SupportScreen());
      case aboutRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: AboutScreen());
      case privacyPolicyRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: PrivacyPolicyScreen());
      case termsAndConditionRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: TermsAndConditionScreen());
      case categoryDetailPageRoute:
        BusinessTypesData category =
            routeSettings.arguments as BusinessTypesData;
        return MaterialPageRoute(
            builder: (_) => CategoryDetailPage(category: category));
      case foodShopPageRoute:
        FoodDeliveryShop singleShopDataId =
            routeSettings.arguments as FoodDeliveryShop;
        return MaterialPageRoute(
          builder: (_) => FoodDeliveryShop(
            singleShopId: singleShopDataId.singleShopId,
            businessTypeId: singleShopDataId.businessTypeId,
          ),
        );
      case searchFoodRoute:
        SearchFood singleShop = routeSettings.arguments as SearchFood;
        return MaterialPageRoute(
          builder: (_) => SearchFood(
            singleShopId: singleShop.singleShopId,
            shopName: singleShop.shopName,
            businessTypeId: singleShop.businessTypeId,
          ),
        );
      case cartScreenRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: CartScreen());

      case selectLocationScreenRoute:
        return Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: SelectLocationScreen());
    }
    return Transitions(
        transitionType: TransitionType.slideUp,
        curve: Curves.bounceInOut,
        reverseCurve: Curves.fastLinearToSlowEaseIn,
        widget: OnBoardScreen());
  }
}
