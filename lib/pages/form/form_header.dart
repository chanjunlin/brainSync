import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({Key? key,
    required this.image,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  final String title, subTitle;
  final Image image;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: const AssetImage("assets/img/people.png"),
          height: size.height * 0.22,
        ),
        Text(
          title,
        ),
        Text(
          subTitle,
        ),
      ],
    );
  }
}
