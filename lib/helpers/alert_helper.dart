import 'package:flutter/material.dart';

showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    showCloseIcon: true,
    content: Text(message),
  ));
}
