import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class ShopFaseWidget extends StatefulWidget {
  const ShopFaseWidget({super.key});

  @override
  State<ShopFaseWidget> createState() => _ShopFaseWidgetState();
}

class _ShopFaseWidgetState extends State<ShopFaseWidget> {
  final GlobalKey<ShopWidgetState> _shopWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          ShopWidget(key: _shopWidgetKey),
          BuyWidget(
            onJokerDropped: (int index) {
              return _shopWidgetKey.currentState?.removeJoker(index);
            },
            onConsumableDropped: (int index) {
              return _shopWidgetKey.currentState?.removeConsumable(index);
            },
            onPackageDropped: (int index) {
              return _shopWidgetKey.currentState?.removePackage(index);
            },
          ),
        ],
      ),
    );
  }
}
