import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nude_checker/flutter_nude_checker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _getNSFWScore() async {
    //get the model file path from assets
    final modelPath = await getModelPath("nsfw.tflite");

    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
          source: ImageSource
              .gallery); // You can also use ImageSource.camera for the camera
      if (image != null) {
        final nsfwScore =
            await FlutterNudeChecker.getNSFWScore(image.path, modelPath);
        if (kDebugMode) {
          print("NSFW Score: ${nsfwScore.nsfwScore}");
        }
        if (kDebugMode) {
          print("SFW Score: ${nsfwScore.sfwScore}");
        }
        if (kDebugMode) {
          print(
            "Time consuming to load data: ${nsfwScore.timeConsumingToLoadData}");
        }
        if (kDebugMode) {
          print(
            "Time consuming to scan data: ${nsfwScore.timeConsumingToScanData}");
        }
        //if nsfwScore.nsfwScore > 0.5, the image is NSFW and show a warning to the user
        if (nsfwScore.nsfwScore > 0.5) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Warning"),
              content: const Text("This image is NSFW"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print("No image selected.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<String> getModelPath(String assetName) async {
    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create a new file in the temporary directory
    final file = File('${tempDir.path}/$assetName');

    // Write the asset content to the new file
    final assetData = await rootBundle.load('assets/$assetName');
    final bytes = assetData.buffer.asUint8List();
    await file.writeAsBytes(bytes, flush: true);

    // Return the file path
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NSFW Checker Example"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _getNSFWScore,
          child: const Text("Get NSFW Score"),
        ),
      ),
    );
  }
}
