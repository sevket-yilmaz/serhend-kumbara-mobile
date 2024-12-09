import 'package:flutter/material.dart';

class BottomSheetButton extends StatelessWidget {
  final Widget icon;
  final Widget text;
  final Color color;
  final VoidCallback onPressed;
  final bool isMin;

  const BottomSheetButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.isMin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isMin ? 30 : 50,
          height: isMin ? 30 : 50,
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          child: MaterialButton(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            height: isMin ? 50 : 75,
            splashColor: Colors.black.withAlpha(30),
            highlightColor: Colors.black.withAlpha(30),
            onPressed: onPressed,
            child: icon,
          ),
        ),
        text,
      ],
    );
  }
}
