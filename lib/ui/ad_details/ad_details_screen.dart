import 'package:harajkhodar/custom_widgets/buttons/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:harajkhodar/custom_widgets/safe_area/page_container.dart';
import 'package:harajkhodar/locale/app_localizations.dart';
import 'package:harajkhodar/models/ad.dart';
import 'package:harajkhodar/models/ad_details.dart';
import 'package:harajkhodar/networking/api_provider.dart';
import 'package:harajkhodar/providers/ad_details_provider.dart';
import 'package:harajkhodar/providers/auth_provider.dart';
import 'package:harajkhodar/providers/favourite_provider.dart';
import 'package:harajkhodar/ui/chat/chat_screen.dart';
import 'package:harajkhodar/ui/seller/seller_screen.dart';
import 'package:harajkhodar/ui/section_ads/section_ads_screen.dart';
import 'package:harajkhodar/utils/app_colors.dart';
import 'package:harajkhodar/utils/commons.dart';
import 'package:harajkhodar/utils/urls.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:harajkhodar/utils/error.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:harajkhodar/ui/ad_details/widgets/slider_images.dart';
import 'package:harajkhodar/providers/home_provider.dart';
import 'package:harajkhodar/ui/comments/comment_bottom_sheet.dart';
import 'package:harajkhodar/ui/comment/comment_screen.dart';
import 'package:harajkhodar/ui/auth/login_screen.dart';
import 'package:harajkhodar/custom_widgets/no_data/no_data.dart';
import 'package:harajkhodar/custom_widgets/custom_text_form_field/custom_text_form_field.dart';

import 'package:harajkhodar/models/comments.dart';
import 'package:harajkhodar/providers/comment_provider.dart';
import 'package:harajkhodar/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:harajkhodar/custom_widgets/custom_text_form_field/custom_text_form_field.dart';
import 'package:harajkhodar/custom_widgets/no_data/no_data.dart';
import 'package:harajkhodar/custom_widgets/safe_area/page_container.dart';
import 'package:harajkhodar/locale/app_localizations.dart';
import 'package:harajkhodar/models/chat_message.dart';
import 'package:harajkhodar/models/chat_msg_between_members.dart';
import 'package:harajkhodar/networking/api_provider.dart';
import 'package:harajkhodar/providers/auth_provider.dart';
import 'package:harajkhodar/providers/chat_provider.dart';
import 'package:harajkhodar/ui/chat/widgets/chat_msg_item.dart';
import 'package:harajkhodar/utils/app_colors.dart';
import 'package:harajkhodar/utils/commons.dart';
import 'package:harajkhodar/utils/error.dart';
import 'package:harajkhodar/utils/urls.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:harajkhodar/ui/home/home_screen.dart';


class AdDetailsScreen extends StatefulWidget {
  final Ad ad;


  const AdDetailsScreen({Key key, this.ad}) : super(key: key);
  @override
  _AdDetailsScreenState createState() =>
      _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
  double _height = 0, _width = 0;
  ApiProvider _apiProvider = ApiProvider();
  AuthProvider _authProvider ;
    BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  HomeProvider _homeProvider;
  String reportValue;


  @override
  void initState() {
      super.initState();
      setCustomMapPin();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/pin.png',);
  }
 
  Widget _buildRow(
      {@required String imgPath,
      @required String title,
      @required String value}) {
    return Row(
      children: <Widget>[
        Image.asset(
          imgPath,
          color: Color(0xffC5C5C5),
          height: 15,
          width: 15,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )),
        Spacer(),
        Text(
          value,
          style: TextStyle(color: Color(0xff5FB019), fontSize: 14),
        ),
      ],
    );
  }


  void _settingModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(15)),
               Container(

                 child: Text(_homeProvider.currentLang=="ar"?"ارسال بلاغ :-":"Send report :-"),
               ),
               Padding(padding: EdgeInsets.all(15)),
                Container(

                  child: CustomTextFormField(
                    hintTxt:  _homeProvider.currentLang=="ar"?"سبب البلاغ":"Report reason",

                    onChangedFunc: (text) async{
                      reportValue = text;
                    },
                  ),

                ),

                CustomButton(
                  btnColor: mainAppColor,
                  btnLbl: _homeProvider.currentLang=="ar"?"ارسال":"Send",
                  onPressedFunction: () async{

                    if(reportValue!=null) {

                      final results = await _apiProvider
                          .post(Urls.REPORT_AD_URL +
                          "?api_lang=${_authProvider.currentLang}", body: {
                        "report_user": _authProvider.currentUser.userId,
                        "report_gid": widget.ad.adsId,
                        "report_value": reportValue,
                      });


                      if (results['response'] == "1") {
                        Commons.showToast(context, message: results["message"]);
                        Navigator.pop(context);
                      } else {
                        Commons.showError(context, results["message"]);
                      }

                    }else{
                      Commons.showError(context, "يجب ادخال سبب البلاغ");
                    }

                  },
                ),

                Padding(padding: EdgeInsets.all(10)),

              ],
            ),
          );
        }
    );
  }

  Widget _buildBodyItem() {
    return   FutureBuilder<AdDetails>(
                  future: Provider.of<AdDetailsProvider>(context,
                          listen: false)
                      .getAdDetails(widget.ad.adsId) ,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Center(
                          child: SpinKitFadingCircle(color: mainAppColor),
                        );
                      case ConnectionState.active:
                        return Text('');
                      case ConnectionState.waiting:
                        return Center(
                          child: SpinKitFadingCircle(color: mainAppColor),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Error(
                            //  errorMessage: snapshot.error.toString(),
                            errorMessage: AppLocalizations.of(context).translate('error'),
                          );
                        } else {
                          List comments= snapshot.data.adsComments;
                         // List related= snapshot.data.adsRelated;
                           var initalLocation = snapshot.data.adsLocation.
     split(','); 
    LatLng pinPosition = LatLng(double.parse(initalLocation[0]), double.parse(initalLocation[1]));
    
    // these are the minimum required values to set 
    // the camera position 
    CameraPosition initialLocation = CameraPosition(
        zoom: 15,
        bearing: 30,
        target: pinPosition
    );

                     
                 return        ListView(
      children: <Widget>[
        SizedBox(
          height: 60,
        ),




        (_homeProvider.omarKey=="1")?GestureDetector(
          child: CustomButton(
            btnLbl: _homeProvider.currentLang=="ar"?"اخفاء المحتوى من هذا المعلن":"Hide content from this advertiser",
            btnColor: mainAppColor,
            onPressedFunction: () async{

              final results = await _apiProvider
                  .post("https://harajkhodhar.com/api/report999" +
                  "?api_lang=${_authProvider.currentLang}", body: {
               // "report_user": _authProvider.currentUser.userId,
                "report_gid": widget.ad.adsId,
                //"report_value": reportValue,
              });


              if (results['response'] == "1") {
                Commons.showToast(context, message: results["message"]);
                Navigator.pop(context);
              } else {
                Commons.showError(context, results["message"]);
              }

            },
          ),
        ):Text(" ",style: TextStyle(height: 0),),

        Container(

          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),

          child: SliderImages(),
        ),



        Container(
          margin: EdgeInsets.symmetric(horizontal: _width * 0.04),
          child:   Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.ad.adsTitle,style: TextStyle(color: Colors.grey[600],fontSize: 25),),
              Spacer(),
              Container(

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: accentColor,

                ),
                  padding: EdgeInsets.all(7),
                  margin: EdgeInsets.only(
                    right: _authProvider.currentLang != 'ar' ? 5 : 0,
                    left:  _authProvider.currentLang == 'ar' ? 5 : 0,
                    top: _height * 0.02,
                  ),
                
                 child: GestureDetector(
                   child: Icon(Icons.report_problem,color: Colors.grey[600],),
                   onTap: () async{
                     _settingModalBottomSheet(context);
                   },
                 ),
                
              )
            ],
          ),
        ),





        Container(
            margin: EdgeInsets.symmetric(horizontal: _width * 0.04),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[


                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: mainAppColor),
                    children: <TextSpan>[
                      new TextSpan(text: snapshot.data.adsPrice),
                      new TextSpan(text: ' '),
                      new TextSpan(
                          text:  AppLocalizations.of(context).translate('sr'),
                          style: new TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: Color(0xff2E2E2E))),
                    ],
                  ),
                )
              ],
            )),


    SizedBox(height: 10,),

        Container(
          height: _height * 0.1,
          padding: EdgeInsets.symmetric(
              horizontal: _width * 0.04, vertical: _height * 0.01),
          decoration: BoxDecoration(

            border: Border.all(
              color: hintColor.withOpacity(0.4),
            ),
            color: Colors.white,

          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: _width * 0.025),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: _height * 0.025,
                  backgroundImage: NetworkImage(snapshot.data.adsUserPhoto),
                ),
              ),
              GestureDetector(
                onTap: (){
                  _homeProvider.setCurrentSeller(snapshot.data.adsUser);
                  _homeProvider.setCurrentSellerName(snapshot.data.adsUserName);
                  _homeProvider.setCurrentSellerPhone(snapshot.data.adsUserPhone);
                  _homeProvider.setCurrentSellerPhoto(snapshot.data.adsUserPhoto);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerScreen
                            (
                            userId: snapshot.data.adsUser,

                          )));

                },
                child: Text(
                  snapshot.data.adsUserName,
                  style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.w600,fontSize: 17),
                ),
              ),
              Spacer(),

               Row(
                 children: <Widget>[
                   Icon(Icons.access_time,size: 18,color: Colors.grey),
                   Text(
                     snapshot.data.adsFullDate,
                     style:
                     TextStyle(color: Colors.grey, fontWeight: FontWeight.w600,fontSize: 17),
                   )
                 ],
               )


            ],
          ),
        ),


        SizedBox(height: 10,),


        Container(
          margin: EdgeInsets.symmetric(
            horizontal: _width * 0.04,
          ),
          child: Text(
            _homeProvider.currentLang=="ar"?"التفاصيل":"Details",
            style: TextStyle(
                color: Colors.grey, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),



        Container(
            margin: EdgeInsets.symmetric(
              horizontal: _width * 0.04,
            ),
            child: Text(
              snapshot.data.adsDetails,
              style: TextStyle(height: 1.4, fontSize: 15),
              textAlign: TextAlign.justify,
            )),


   SizedBox(height: 20,),





        Container(

            margin: EdgeInsets.only(top: 10,right: 30,left: 30),
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: mainAppColor.withOpacity(0.8),
              ),
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25),bottomRight: Radius.circular(25),bottomLeft: Radius.circular(25)),
            ),
            child:   GestureDetector(
                onTap: (){
                  if (_authProvider.currentUser != null) {

                    Navigator.push(context, MaterialPageRoute
                      (builder: (context)=> ChatScreen(
                      senderId: snapshot.data.userDetails[0].id,
                      senderImg: snapshot.data.userDetails[0].userImage,
                      senderName:snapshot.data.userDetails[0].name,
                      senderPhone:snapshot.data.adsPhone,
                      adsId:snapshot.data.adsId,

                    )
                    ));
                  } else {
                    Navigator.pushNamed(
                        context, '/login_screen');
                  }
                },
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.chat,color: mainAppColor,)),
                    Text(
                      AppLocalizations.of(context).translate('send_to_advertiser'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color:mainAppColor),
                    ),

                  ],
                ))),

        SizedBox(height: 10,),



        Container(
          margin: EdgeInsets.symmetric(
            horizontal: _width * 0.04,
          ),
          child: Text(
            _homeProvider.currentLang=="ar"?"عرض التعليقات":"ٍShow comments",
            style: TextStyle(
                color: Colors.grey, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),



          Container(

            height: 250,
            margin: EdgeInsets.symmetric(
              horizontal: _width * 0.04,
            ),
            child: FutureBuilder<List<Comments>>(
                future: Provider.of<CommentProvider>(context, listen: false)
                    .getCommentsList(_homeProvider.currentAds),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return SpinKitFadingCircle(color: mainAppColor);
                    case ConnectionState.active:
                      return Text('');
                    case ConnectionState.waiting:
                      return SpinKitFadingCircle(color: mainAppColor);
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return NoData(
                          message:
                          _homeProvider.currentLang=="ar"?"لا يوجد تعليقات":"No comments found",
                        );
                      } else {
                        if (snapshot.data.length > 0) {
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    border: Border.all(
                                      color: hintColor.withOpacity(0.4),
                                    ),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  width: _width,
                                  height: _height * 0.13,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(snapshot.data[index].commentBy,style: TextStyle(fontSize: 14,color: Colors.grey[900])),
                                          Padding(padding: EdgeInsets.all(2)),
                                          Container(
                                            width: 300,
                                            child: Text(snapshot.data[index].commentDetails,style: TextStyle(fontSize: 16,color: mainAppColor,),maxLines: 2,),
                                          ),
                                          Text(snapshot.data[index].commentDate,style: TextStyle(fontSize: 14,color: Colors.grey[900])),
                                        ],
                                      )


                                    ],
                                  ),
                                );
                              });
                        } else {
                          return NoData(
                            message:
                            AppLocalizations.of(context).translate('no_msgs'),
                          );
                        }
                      }
                  }
                  return SpinKitFadingCircle(color: mainAppColor);
                }),
          ),



        Container(
            margin: EdgeInsets.only(top: 5,bottom: 35,right: 15,left: 15),
            height: 50,
            decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10), topRight: Radius.circular(10),bottomRight:  Radius.circular(10)
                    ,bottomLeft:  Radius.circular(10)),
                border: Border.all(
                  color: Color(0xffABABAB),
                  width: 1,
                )
            ),
            child:   GestureDetector(
                onTap: (){

                  if(_authProvider.currentUser==null){

                    Commons.showToast(context,
                        message: "يجب عليك تسجيل الدخول اولا");

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen()));

                  }else{

                    _homeProvider.setCurrentAds(widget.ad.adsId);

                    Navigator.push(context, MaterialPageRoute
                      (builder: (context)=> CommentScreen()
                    ));




                  }

                },
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "اضافة تعليق",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Color(0xffABABAB)),
                      ),),


                  ],
                ))),


//Text(snapshot.data.adsLocation),
        snapshot.data.adsLocation!="2.1,2.1"?
Container(
  margin: EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 7
  ),
  height: 150,
   decoration: BoxDecoration(
              color:  Color(0xffF3F3F3),
              border: Border.all(
                width: 1.0,
                color: Color(0xffF3F3F3),
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
  child:   ClipRRect(
    borderRadius: BorderRadius.all( Radius.circular(10.0)),
    child: GoogleMap(

        myLocationEnabled: true,

        compassEnabled: true,

        markers: _markers,

        initialCameraPosition: initialLocation,

        onMapCreated: (GoogleMapController controller) {

            controller.setMapStyle(Commons.mapStyles);

            _controller.complete(controller);



     setState(() {

              _markers.add(

                  Marker(

                    markerId: MarkerId(snapshot.data.adsId),

                    position: pinPosition,

                    icon: pinLocationIcon

                  )

              );





  });



        })),
):Text(""),
        
        
        
        
        
        
        
        

        Container(
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            height: 50,
            decoration: BoxDecoration(
              color: mainAppColor,

            ),
            child:       GestureDetector(
              onTap: (){
                launch(
                    "tel://${snapshot.data.adsPhone}");
              },
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: _width * 0.025),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.phone,color: Colors.white,size: 20,),
                     Text(snapshot.data.adsPhone,style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)
                    ],
                  )),
            )),


        SizedBox(
          height: 5,
        ),





    
      ],
    );
                        }
                    }
                    return Center(
                      child: SpinKitFadingCircle(color: mainAppColor),
                    );
                  });
   
  }

  @override
  Widget build(BuildContext context) {
    _height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    _width = MediaQuery.of(context).size.width;
    _authProvider = Provider.of<AuthProvider>(context);
    _homeProvider = Provider.of<HomeProvider>(context);
    return PageContainer(
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          _buildBodyItem(),
          Container(
              height: 60,
              decoration: BoxDecoration(
                color: mainAppColor,

              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Consumer<AuthProvider>(
                      builder: (context,authProvider,child){
                        return authProvider.currentLang == 'ar' ? Icon(Icons.arrow_back,size: 25,color: Colors.white,): Transform.rotate(
                            angle: 180 * math.pi / 180,
                            child:  Icon(Icons.arrow_back,size: 25,color: Colors.white,));
                      },
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },),
                   Container(
                     width: _width *0.55,
                     child: Text( widget.ad.adsTitle,
                     overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline1),
                   ),
                  
                  Spacer(
                    flex: 3,
                  ),
                  _authProvider.currentUser == null
                      ? GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, '/login_screen'),
                    child: Center(
                        child: Icon(
                          Icons.favorite_border,
                          size: 38,
                          color: Colors.white,
                        )),
                  )
                      : Consumer<FavouriteProvider>(builder:
                      (context, favouriteProvider,
                      child) {
                    return GestureDetector(
                      onTap: () async {
                        if (favouriteProvider
                            .favouriteAdsList
                            .containsKey(widget.ad.adsId)) {
                          favouriteProvider
                              .removeFromFavouriteAdsList(
                              widget.ad.adsId);
                          await _apiProvider.get(Urls
                              .REMOVE_AD_from_FAV_URL +
                              "ads_id=${widget.ad.adsId}&user_id=${_authProvider.currentUser.userId}");
                        } else {
                          favouriteProvider
                              .addToFavouriteAdsList(
                              widget.ad.adsId,
                              1);
                          await _apiProvider.post(
                              Urls.ADD_AD_TO_FAV_URL,
                              body: {
                                "user_id":
                                _authProvider
                                    .currentUser
                                    .userId,
                                "ads_id": widget.ad.adsId
                              });
                        }
                      },
                      child: Center(
                        child: favouriteProvider
                            .favouriteAdsList
                            .containsKey(
                            widget.ad.adsId)
                            ? SpinKitPumpingHeart(
                          color: accentColor,
                          size: 25,
                        )
                            : Icon(
                          Icons.favorite_border,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
                  Container(
                    width: _width * 0.02,
                  ),
                  IconButton(
                    onPressed: (){
                        Share.share("http://harajkhodhar.com/site/show/" + widget.ad.adsId,
                                  subject: widget.ad.adsDetails,
                          
                        );
                    },
                  icon:  Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 30,
                  ),
                  )
                  ,
                 Container(
                    width: _width * 0.02,
                  ),
                ],
              )),




        ],
      )),
    );
  }
}
