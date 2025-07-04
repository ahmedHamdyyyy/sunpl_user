import 'package:userapp/models/slider_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:validators/validators.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late Future<List<SliderModel>> futureSliderList;

  @override
  void initState() {
    futureSliderList = AppData().getSliders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SliderModel>>(
      future: futureSliderList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CarouselSlider.builder(
            options: CarouselOptions(
                height: snapshot.data!.isEmpty ? 0 : 150.0,
                autoPlay: snapshot.data!.length > 1,
                enableInfiniteScroll: snapshot.data!.length > 1),
            itemCount: snapshot.data!.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              SliderModel slider = snapshot.data![itemIndex];
              return Container(
                  width: context.media.size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: !isHexColor(slider.color!)
                        ? const Color(0xffffffff)
                        : Color(int.parse("0xff${slider.color!}")),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: slider.image!,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(),
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.3)),
                      ),
                      Center(
                        child: ListTile(
                          title: Headline6(
                            slider.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Subtitle1(
                            slider.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ));
            },
          );
        } else if (snapshot.hasError) {
          return Card(
            elevation: 0.0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Ionicons.planet_outline,
                      size: 50,
                    ),
                    Subtitle1(
                      snapshot.error.toString().contains('لا يمكن الاتصال') ||
                      snapshot.error.toString().contains('انتهت مهلة') ||
                      snapshot.error.toString().contains('Connection')
                          ? snapshot.error.toString()
                          : "sww".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureSliderList = AppData().getSliders();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "إعادة المحاولة"
                            : "Retry",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Shimmer(
          color: Colors.grey,
          child: const Card(
            margin: EdgeInsets.all(4),
            child: SizedBox(
              height: 150,
            ),
          ),
        );
      },
    );
  }
}
