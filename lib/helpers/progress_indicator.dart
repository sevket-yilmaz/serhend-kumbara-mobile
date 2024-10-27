import 'dart:ui';

import 'package:flutter/material.dart';

Widget drawProgressIndicator() {
  return Material(
    type: MaterialType.transparency,
    child: Container(
      height: double.maxFinite,
      width: double.maxFinite,
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //       image: ExactAssetImage("assets/mosque1.png"),
      //       fit: BoxFit.cover,
      //       colorFilter: ColorFilter.mode(
      //         Colors.grey,
      //         BlendMode.saturation,
      //       )),
      // ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            alignment: Alignment.center,
            color: Colors.white.withOpacity(0.7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "YÜKLENİYOR",
                  style: TextStyle(color: Colors.green.shade900, fontSize: 35),
                ),
                Text(
                  "Lütfen bekleyiniz..",
                  style: TextStyle(color: Colors.green.shade900, fontSize: 20),
                ),
                const SizedBox(height: 50),
                Image.asset(
                  "assets/loading.gif",
                  height: 120,
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
