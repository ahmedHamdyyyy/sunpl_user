import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:get_storage/get_storage.dart';
import 'package:userapp/main.dart';
import 'package:userapp/models/order_item_model.dart';
import 'package:userapp/models/order_model.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class CheckoutPage extends StatefulWidget {
  final List<OrderItemModel> orderItems;
  final double totalPrice;

  const CheckoutPage(
      {Key? key, required this.orderItems, required this.totalPrice})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String payment = "Cash on delivery";
  String userAddress = "";

  LatLng? currentLatLng;
  bool isMapLoading = true;

  final Completer<GoogleMapController> _controller = Completer();

  getUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if Location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the Location services.
        setState(() {
          userAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "خدمات الموقع غير مفعلة"
              : "Location services are disabled";
          isMapLoading = false;
          // Set a default location (Damascus, Syria) even when location services are disabled
          currentLatLng = const LatLng(33.5138, 36.2765);
        });

        selectedPos = Marker(
          markerId: const MarkerId("selectedPos"),
          position: currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        return;
      }

      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Location permissions are denied
          setState(() {
            userAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? "تم رفض صلاحيات الموقع"
                : "Location permissions are denied";
            isMapLoading = false;
            // Set a default location (Damascus, Syria)
            currentLatLng = const LatLng(33.5138, 36.2765);
          });

          selectedPos = Marker(
            markerId: const MarkerId("selectedPos"),
            position: currentLatLng!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          userAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "صلاحيات الموقع مرفوضة نهائياً"
              : "Location permissions are permanently denied";
          isMapLoading = false;
          // Set a default location (Damascus, Syria)
          currentLatLng = const LatLng(33.5138, 36.2765);
        });

        selectedPos = Marker(
          markerId: const MarkerId("selectedPos"),
          position: currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude);
      });

      selectedPos = Marker(
        markerId: const MarkerId("selectedPos"),
        position: currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      await getAddressData();

      setState(() {
        isMapLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      setState(() {
        userAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? "خطأ في الحصول على الموقع"
            : "Error getting location";
        isMapLoading = false;
        // Set a default location (Damascus, Syria)
        currentLatLng = const LatLng(33.5138, 36.2765);
      });

      selectedPos = Marker(
        markerId: const MarkerId("selectedPos"),
        position: currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }
  }

  getAddressData() async {
    try {
      if (currentLatLng == null) return;

      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: currentLatLng!.latitude,
          longitude: currentLatLng!.longitude,
          googleMapApiKey: AppConst.googleMapApiKey);

      setState(() {
        userAddress = data.address.isNotEmpty
            ? data.address
            : LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? "الموقع المحدد"
                : "Selected Location";
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting address: $e");
      }
      setState(() {
        userAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? "الموقع المحدد"
            : "Selected Location";
      });
    }
  }

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }

  Marker? selectedPos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  backgroundColor: Colors.white,
        title: Headline6("checkout".tr(),
            style: const TextStyle(
                color: AppThemes.lightGreyColor, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: Headline6("items".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Headline6("${widget.orderItems.length}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  GridView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6),
                      itemCount: widget.orderItems.length,
                      itemBuilder: (context, index) {
                        OrderItemModel orderItem = widget.orderItems[index];
                        // Get the best available image
                        String imageUrl = '';
                        if (orderItem.product.hasMultipleImages) {
                          // Use the first image from the images list
                          imageUrl = orderItem.product.allImages.first;
                        } else if (orderItem.product.image.isNotEmpty) {
                          // Use the main image
                          imageUrl = orderItem.product.image;
                        } else {
                          // Fallback to placeholder
                          imageUrl = '${AppConst.url}/placeholder.jpg';
                        }
                        
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Tooltip(
                              message: orderItem.product.title,
                              child: Card(
                                color: context.color.scaffold,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0.0,
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Ionicons.image_outline,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                  memCacheWidth: 200,
                                  memCacheHeight: 200,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.blueGrey,
                                child: BodyText1(
                                  "${orderItem.qty}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                            // Show indicator if product has multiple images
                            if (orderItem.product.hasMultipleImages)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Ionicons.images_outline,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                ListTile(
                  title: Subtitle1("selectLocation".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Headline6(userAddress),
                ),
                Container(
                  height: Get.width * .7,
                  padding: const EdgeInsets.all(8),
                  child: currentLatLng == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                LocalizeAndTranslate.getLanguageCode() == 'ar'
                                    ? "جاري تحديد الموقع..."
                                    : "Getting location...",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GoogleMap(
                            gestureRecognizers: <Factory<
                                OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                            onTap: (latlng) {
                              setState(() {
                                currentLatLng = latlng;
                                selectedPos = Marker(
                                  markerId: const MarkerId("selectedPos"),
                                  position: latlng,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueRed),
                                );
                              });
                              getAddressData();
                            },
                            myLocationButtonEnabled: true,
                            mapToolbarEnabled: false,
                            myLocationEnabled: true,
                            mapType: MapType.normal,
                            zoomControlsEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: currentLatLng!,
                              zoom: 15,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              if (!_controller.isCompleted) {
                                _controller.complete(controller);
                              }
                            },
                            markers: selectedPos != null ? {selectedPos!} : {},
                          ),
                        ),
                ),
              ],
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: Headline6("paymentMethode".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  RadioListTile(
                    title: Text("cashOnDelivery".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    value: "Cash on delivery",
                    groupValue: payment,
                    secondary: const Icon(Ionicons.cube),
                    onChanged: (value) {
                      setState(() {
                        payment = "$value";
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: Text("subtotal".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                        "${widget.totalPrice} ${AppConst.appCurrency}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: Text("deliveryFee".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Text(
                        "${AppConst.fee} ${AppConst.appCurrency}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: Text("total".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                        "${widget.totalPrice + AppConst.fee} ${AppConst.appCurrency}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.color.primary)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                // التحقق من وجود الموقع قبل المتابعة
                if (currentLatLng == null) {
                  Get.snackbar(
                    LocalizeAndTranslate.getLanguageCode() == 'ar'
                        ? "خطأ"
                        : "Error",
                    LocalizeAndTranslate.getLanguageCode() == 'ar'
                        ? "يرجى تحديد موقع التوصيل أولاً"
                        : "Please select delivery location first",
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                    icon: const Icon(Ionicons.location_outline,
                        color: Colors.red),
                    duration: const Duration(seconds: 3),
                  );
                  return;
                }

                if (userAddress.isEmpty) {
                  setState(() {
                    userAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
                        ? "الموقع المحدد"
                        : "Selected Location";
                  });
                }

                /*print("${List.generate(widget.orderItems.length, (index) => json.encode(widget.orderItems[index].toJson())).toList()}");*/
                AppWidgets().MyDialog(
                    context: context,
                    title: "loading",
                    background: AppThemes.primaryColor,
                    asset:
                        const CircularProgressIndicator(color: Colors.white));
                AppData()
                    .addOrder(
                        orderModel: OrderModel(
                            orderItems:
                                "${List.generate(widget.orderItems.length, (index) => json.encode(widget.orderItems[index].toJson())).toList()}",
                            userLocation: userAddress,
                            userPhone: jsonDecode(
                                GetStorage().read("currentuser"))["phone"]!,
                            userLatLng:
                                "${currentLatLng!.latitude},${currentLatLng!.longitude}",
                            passcode: Random()
                                .nextInt(9999)
                                .toString()
                                .padLeft(4, '0'),
                            userUid: '',
                            statusId: 0))
                    .then((value) {
                  cartItemsNotifier = ValueNotifier(<OrderItemModel>[]);
                  Get.back();
                  if (kDebugMode) {
                    print(value);
                  }
                  if (value['type'] == "success") {
                    AppWidgets().MyDialog(
                        context: context,
                        asset: const Icon(
                          Ionicons.checkmark_circle,
                          size: 80,
                          color: Colors.white,
                        ),
                        background: context.color.primary,
                        title: "orderCreated".tr(),
                        confirm: ElevatedButton(
                            onPressed: () {
                              Get.offAll(() => const MainPage(
                                    selectedIndex: 3,
                                  ));
                            },
                            child: Text("ok".tr())));
                  } else {
                    AppWidgets().MyDialog(
                        context: context,
                        asset: const Icon(
                          Ionicons.close_circle,
                          size: 80,
                          color: Colors.white,
                        ),
                        background: const Color(0xffDF2E2E),
                        title: "orderNotCreated".tr(),
                        confirm: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("back".tr())));
                  }
                }).catchError((error) {
                  Get.back();
                  if (kDebugMode) {
                    print("Order error: $error");
                  }
                  AppWidgets().MyDialog(
                      context: context,
                      asset: const Icon(
                        Ionicons.close_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                      background: const Color(0xffDF2E2E),
                      title: LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "خطأ في إنشاء الطلب"
                          : "Order Creation Error",
                      confirm: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text("back".tr())));
                });
              },
              tileColor: context.color.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Center(
                child: Headline6(
                  "checkout".tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
