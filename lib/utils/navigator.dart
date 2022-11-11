import 'package:flutter/cupertino.dart';

class MyNavigator {
  static Route createRoute(Widget route, {bool isAnimated = false}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => route,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = (isAnimated) ? Offset(1.0, 0.0) : Offset.zero;
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
