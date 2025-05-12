import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String base64Image;

  const ImageDisplay({Key? key, required this.base64Image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decodedImage = base64Decode(base64Image);
    return Image.memory(Uint8List.fromList(decodedImage));
  }
}
