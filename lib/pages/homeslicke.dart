import 'package:flutter/material.dart';

class HomeSlicke extends StatelessWidget {
  const HomeSlicke({super.key});

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;

    double w = sw * 0.25;

    double topCenter = sh * 0.35;
    double margin = sw * 0.05;

    print(sh.toDouble());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Degas'),
      ),
      body: Stack(
        children: [
          //center
          Positioned(
            top: topCenter,
            left: sw * 0.5 - w * 0.5,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                print('deg');
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
              ),
            ),
          ),

          //top left
          Positioned(
            top: topCenter - w - w * 0.1,
            left: sw * 0.5 - w * 0.5 - w * 0.6,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                print('deg');
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
              ),
            ),
          ),

          //top right
          Positioned(
            top: topCenter - w - w * 0.1,
            left: sw * 0.5 - w * 0.5 + w * 0.6,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                print('deg');
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
              ),
            ),
          ),

          //left
          Positioned(
            top: topCenter,
            left: sw * 0.5 - w * 0.5 - w - w * 0.2,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                print('deg');
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
              ),
            ),
          ),

          //right
          Positioned(
            top: topCenter,
            left: sw * 0.5 - w * 0.5 + w + w * 0.2,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                print('deg');
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
              ),
            ),
          ),

          //bottom
          Positioned(
            top: topCenter + w + margin,
            left: sw * 0.5 - w * 0.5,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                print('deg');
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}