import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:userapp/utils/helpers_replacement.dart';

class AppWidgets {
  // ignore: non_constant_identifier_names
  MyDialog(
          {required BuildContext context,
          String? title,
          String? subtitle,
          Color? background,
          Widget? confirm,
          Widget? cancel,
          required Widget asset}) =>
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return PopScope(
              onPopInvoked: (didPop) async {
                if (didPop) return;
              },
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: background,
                      child: Center(child: asset),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          title != null ? Headline6(title) : const SizedBox(),
                          subtitle != null
                              ? Body1(
                                  subtitle,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          confirm ?? const SizedBox(),
                          const SizedBox(
                            width: 10,
                          ),
                          cancel ?? const SizedBox(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });

  // ignore: non_constant_identifier_names
  EmptyDataWidget({
    required String title,
    required IconData icon,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: Get.size.width / 2,
          ),
          Headline5(
            title,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
