import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:grabbito/model/book_order_model.dart';
import 'package:grabbito/model/booking_order_for_package.dart';
import 'package:grabbito/model/homepage/banner_model.dart';
import 'package:grabbito/model/homepage/business_types_model.dart';
import 'package:grabbito/model/homepage/offers_at_fruit_veg_model.dart';
import 'package:grabbito/model/homepage/offers_at_grocery_model.dart';
import 'package:grabbito/model/homepage/offers_at_restaurant_model.dart';
import 'package:grabbito/model/homepage/offers_model.dart';
import 'package:grabbito/model/homepage/order_history_model.dart';
import 'package:grabbito/model/login_model.dart';
import 'package:grabbito/model/register_model.dart';
import 'package:grabbito/model/search_model.dart';
import 'package:grabbito/model/setting_model.dart';
import 'package:grabbito/model/shops_model.dart';
import 'package:grabbito/model/show_all_location_model.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/model/single_shop_search.dart';
import 'package:grabbito/model/singleorder_package.dart';
import 'package:grabbito/model/support_model.dart';
import 'package:grabbito/model/track_order_model.dart';
import 'package:grabbito/network/api_constant.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: Api.baseUrl)
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  @POST(Api.login)
  @FormUrlEncoded()
  Future<LoginModel> login(@Body() Map<String, dynamic> map);

  @POST(Api.register)
  @FormUrlEncoded()
  Future<RegisterModel> register(@Body() Map<String, dynamic> map);

  @POST(Api.sendOtp)
  @FormUrlEncoded()
  Future<String> sendOtp(@Body() Map<String, dynamic> map);

  @POST(Api.forgotPassword)
  @FormUrlEncoded()
  Future<String> forgotPassword(@Body() Map<String, dynamic> map);

  @POST(Api.checkOtp)
  @FormUrlEncoded()
  Future<String> checkOtp(@Body() Map<String, dynamic> map);

  @POST(Api.addLocation)
  @FormUrlEncoded()
  Future<String> addLocation(@Body() Map<String, dynamic> map);

  @POST(Api.foodOffer)
  @FormUrlEncoded()
  Future<OffersAtRestaurantModel> offersAtRestaurant(
      @Body() Map<String, dynamic> map);

  @POST(Api.groceryOffer)
  @FormUrlEncoded()
  Future<OffersAtGroceryModel> offersAtGrocery(
      @Body() Map<String, dynamic> map);

  @POST(Api.fruitOffer)
  @FormUrlEncoded()
  Future<OffersAtFruitsModel> offersAtFruit(@Body() Map<String, dynamic> map);

  @POST(Api.updateProfile)
  @FormUrlEncoded()
  Future<String> updateProfile(@Body() Map<String, dynamic> map);

  @POST(Api.updateProfile)
  @FormUrlEncoded()
  Future<String> updateProfileForNotification(
    @Field() String notification,
  );

  @GET(Api.user)
  @FormUrlEncoded()
  Future<String> userProfile();

  @POST(Api.changePassword)
  @FormUrlEncoded()
  Future<String> changePassword(@Body() Map<String, dynamic> map);

  @GET(Api.banner)
  @FormUrlEncoded()
  Future<BannerModel> banner();

  @GET(Api.businessType)
  @FormUrlEncoded()
  Future<BusinessTypesModel> businessType();

  @GET(Api.offers)
  @FormUrlEncoded()
  Future<OffersModel> offers();

  @GET(Api.orderHistory)
  @FormUrlEncoded()
  Future<OrderHistoryModel> orderHistory();

  @GET(Api.locations)
  @FormUrlEncoded()
  Future<ShowAllLocationModel> showAllLocation();

  @GET("${Api.deleteLocation}/{id}")
  @FormUrlEncoded()
  Future<String> deleteLocation(@Path() int? id);

  @POST(Api.search)
  @FormUrlEncoded()
  Future<SearchModel> searchApi(@Body() Map<String, dynamic> map);

  @POST("${Api.updateLocation}/{id}")
  @FormUrlEncoded()
  Future<String> updateLocation(
      @Path() int? id, @Body() Map<String, dynamic> map);

  @GET(Api.setting)
  @FormUrlEncoded()
  Future<SettingModel> settingApi();

  @GET(Api.support)
  @FormUrlEncoded()
  Future<SupportModel> support();

  @POST("${Api.shops}/{id}")
  @FormUrlEncoded()
  Future<ShopsModel> shopApi(
    @Path() int? id,
    @Field() String lat,
    @Field() String lang,
  );

  //for others shops like grocery etc.
  @POST("${Api.singleShop}/{id}")
  @FormUrlEncoded()
  Future<SingleShopModel> singleShopApi(
    @Path() int? id,
    @Field() String lat,
    @Field() String lang,
  );

  //for food api pass (type like veg,nonVeg)
  @POST("${Api.singleShop}/{id}")
  @FormUrlEncoded()
  Future<SingleShopModel> singleShopApiOnlyFood(
    @Path() int? id,
    @Field() String lat,
    @Field() String lang,
    @Field() String type,
  );

  @POST(Api.sendPackage)
  @FormUrlEncoded()
  Future<SendPackage> pickupAndDropPayment(@Body() body);

  @POST(Api.checkOffer)
  @FormUrlEncoded()
  Future<String> checkOffer(
    @Field() String code,
    @Field() String date,
    @Field() String amount,
  );

  @POST(Api.bookOrder)
  @FormUrlEncoded()
  Future<BookOrderModel> bookOrder(@Body() body);

  @GET("${Api.singleOrder}/{id}")
  @FormUrlEncoded()
  Future<TrackOrderModel> trackOrder(@Path() int? id);

  @GET("${Api.singlePackageOrder}/{id}")
  @FormUrlEncoded()
  Future<SinglePackageOrder> trackOrderForPackage(@Path() int? id);

  @POST(Api.shopSearch)
  @FormUrlEncoded()
  Future<SingleShopSearchModel> singleShopSearch(
      @Body() Map<String, dynamic> map);

  @GET(Api.trackUserOrder)
  @FormUrlEncoded()
  Future<BookOrderModel> trackLiveOrder();

  @GET("${Api.driverTrackOrder}/{id}/{from}")
  @FormUrlEncoded()
  Future<String> driverTrackOrder(@Path() int? id, @Path() String? from);
}
