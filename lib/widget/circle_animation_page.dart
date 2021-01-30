import 'package:flutter/material.dart';
class CircleAnimationPage extends StatefulWidget {
  final Widget album;
  CircleAnimationPage(this.album);
  @override
  _CircleAnimationPageState createState() => _CircleAnimationPageState();
}

class _CircleAnimationPageState extends State<CircleAnimationPage> with SingleTickerProviderStateMixin{
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this,duration: Duration(milliseconds: 5000));
    controller.forward();
    controller.repeat();
  }
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0,end: 1.0).animate(controller),
      child: widget.album,
    );
  }
}
