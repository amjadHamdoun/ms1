import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:mstand/home/home.dart';
import 'package:mstand/intro_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../language_constants.dart';

class SubBlock extends StatefulWidget {
 final  bool showToast;
  const SubBlock({Key? key,required this.showToast}) : super(key: key);

  @override
  State<SubBlock> createState() => _SubBlockState();
}
const List<String> _kProductIds = <String>[
  'pr1',
  '1',
];

class _SubBlockState extends State<SubBlock> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future setUserInfo(bool isSub) async {
    final db = FirebaseFirestore.instance;
    Map<String, Object?> userInfo = {
      "isSub": isSub,
    };
    await db
        .collection('users')
        .doc(auth.currentUser!.phoneNumber)
        .update(userInfo);

    Fluttertoast.showToast(
      // ignore: use_build_context_synchronously
      msg: translation(context).endSub,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }


  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  Map<String, PurchaseDetails> purchases = {};

  @override
  void initState() {



    purchases =  Map<String, PurchaseDetails>.fromEntries(
        _purchases.map((PurchaseDetails purchase) {
          if (purchase.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchase);
          }
          return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
        }));
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails>
    purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {

    });
    initStoreInfo();
    if(widget.showToast)
      {
        setUserInfo(false);
      }

    super.initState();
  }

  Future<void> initStoreInfo() async {


    try{
      final bool isAvailable = await _inAppPurchase.isAvailable();

      if (!isAvailable) {
        setState(() {
          _products = <ProductDetails>[];
          _purchases = <PurchaseDetails>[];
        });
        return;
      }

      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
        _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      final ProductDetailsResponse productDetailResponse =
      await _inAppPurchase.queryProductDetails(_kProductIds.toSet());

      if (productDetailResponse.error != null) {
        setState(() {
          _products = productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];

        });
        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        setState(() {
          _products = productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];
        });
        return;
      }


      setState(() {
        _products = productDetailResponse.productDetails;
      });
    }
    catch(e){

    }


  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {

      }
      else {



        if(purchaseDetails.status == PurchaseStatus.purchased)
        {
          if(purchaseDetails.productID=='pr1')
          {
            final db = FirebaseFirestore.instance;
            db
                .collection('users')
                .doc(auth.currentUser!.phoneNumber)
                .get()
                .then((value) async {
              DateTime newDate = DateTime.now()
                  .add(const Duration(days: 30));

              Map<String, Object?> userInfo = {
                "isSub": true,
                "subDate": newDate,
              };
              await db
                  .collection('users')
                  .doc(auth.currentUser!.phoneNumber)
                  .update(userInfo)
                  .then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ),
                );
              });
            });
          }

        }


      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
      _inAppPurchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final BillingResultWrapper priceChangeConfirmationResult =
      await androidAddition.launchPriceChangeConfirmationFlow(
        sku: 'purchaseId',
      );
      if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Price change accepted'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            priceChangeConfirmationResult.debugMessage ??
                'Price change failed with code ${priceChangeConfirmationResult.responseCode}',
          ),
        ));
      }
    }
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition
      iapStoreKitPlatformAddition =
      _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      body: ListView(
        children: [
          Stack(
            children: [
              SizedBox(
                width: width,
                child: Image.asset(
                  'assets/login_logo/select_lang.png',
                  height: MediaQuery.of(context).size.height*0.4,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.1),
              ),
              Center(
                  child: Text(
                    translation(context).busBag,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.11,
                      fontWeight: FontWeight.w900,
                    ),
                  )),
            ],
          ),
          Container(
              width: width,
              color: Colors.grey.withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        'assets/logos/premium.png',
                        width: width * 0.15,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      translation(context).subNowInMyapp,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.04,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  for(var prod in _products)
                    if(prod.id=="pr1")
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FadeInUp(
                      child: Container(
                        width: width,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xffFF8C00),
                              Color(0xffFFD700),
                            ],
                          ),
                        ),
                        child: MaterialButton(
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    translation(context).monthly,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                   Text(
                                    ' ${prod.price}',
                                    style:const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )),
                          onPressed: () async {
                            late PurchaseParam purchaseParam;

                            if (Platform.isAndroid) {
                              purchaseParam = GooglePlayPurchaseParam(
                                  productDetails: prod,
                                  applicationUserName: null,
                                  changeSubscriptionParam: null);

                            }
                            else {
                              purchaseParam = PurchaseParam(
                                productDetails: prod,
                                applicationUserName: null,
                              );
                            }
                            if (Platform.isAndroid) {

                              await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                            } else if (Platform.isIOS) {
                              await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
                            }

                          },
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        AwesomeNotifications().actionSink.close();
                        AwesomeNotifications().displayedSink.close();
                        AwesomeNotifications().cancelAllSchedules();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IntroScreen(),
                          ),
                        );
                      });
                    },
                    child: Text(
                      translation(context).singOutSub,
                      style: TextStyle(
                        fontSize: width * 0.030,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {

  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront)
  {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }

}