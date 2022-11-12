
import 'package:flutter/cupertino.dart';

class feedScreen extends StatefulWidget {
  const feedScreen({super.key});

  @override
  feedScreenState createState() => feedScreenState();
}


class feedScreenState extends State<feedScreen> {
  @override


  Widget degustacion(degustacion){
    return Column(
      children: [
        Stack(
          children:const [
                AspectRatio(aspectRatio: 9/16,
                  child: Image(image: AssetImage("assets/images/degustacion.jpg"), fit: BoxFit.cover,),
                ),
          ]

        )
      ],
    );
  }

  Widget build(BuildContext context) {
    List<Widget> degustaciones =  [];
    final PageController controller = PageController(initialPage: 0);

    return PageView(
      scrollDirection: Axis.vertical,
      controller: controller,
      children: degustaciones,
    );
  }

}