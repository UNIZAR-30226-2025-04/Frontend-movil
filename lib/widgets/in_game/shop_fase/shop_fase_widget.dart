import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class ShopFaseWidget extends StatefulWidget {
  const ShopFaseWidget({super.key});

  @override
  State<ShopFaseWidget> createState() => _ShopFaseWidgetState();
}

class _ShopFaseWidgetState extends State<ShopFaseWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      //height: 270,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ShopWidget(),
    );
  }
}
