import 'package:flutter/material.dart';

class FondoWidget extends StatelessWidget {
  final Widget? child;

  const FondoWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/fondo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
