import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_camera_detection/feature/ml_kit/view/id_card_scan_page.dart';
import 'package:test_camera_detection/feature/ml_kit/view/liveness_ekyc_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? livenessFile;
  XFile? scanIDFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FaceLivenessEkycPage()),
                  ).then((file) {
                    setState(() {
                      livenessFile = file;
                    });
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    border: Border.all(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Liveness EKYC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.orange),
                ),
                child:
                    livenessFile != null
                        ? Image.file(
                          File((livenessFile ?? XFile('')).path),
                          fit: BoxFit.contain,
                        )
                        : SizedBox(
                          child: Center(
                            child: Text(
                              'Preview',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 2,
                              ),
                            ),
                          ),
                        ),
              ),
              SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IdCardScanPage()),
                  ).then((file) {
                    setState(() {
                      scanIDFile = file;
                    });
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    border: Border.all(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Scan ID Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.orange),
                ),
                child:
                    scanIDFile != null
                        ? Image.file(
                          File((scanIDFile ?? XFile('')).path),
                          fit: BoxFit.contain,
                        )
                        : SizedBox(
                          child: Center(
                            child: Text(
                              'Preview',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 2,
                              ),
                            ),
                          ),
                        ),
              ),
              Spacer(),
              Image.network(
                'https://assets.brandinside.asia/uploads/2021/05/1620365513924..jpg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
