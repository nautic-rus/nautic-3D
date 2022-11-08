import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'render.dart';

class QrReader extends StatefulWidget {
  const QrReader({Key? key}) : super(key: key);

  @override
  State<QrReader> createState() => _QrReaderState();
}

class _QrReaderState extends State<QrReader> {
  Barcode? barcode;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrViewOpened = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  // @override
  // void deactivate() {
  //   // TODO: implement deactivate
  //   super.deactivate();
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  // }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildQrView(context),
              Positioned(
                child: buildControlButtons(),
                bottom: 40,
              )
            ],
          ),
        ));
  }

  Widget buildControlButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white24,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
              icon: FutureBuilder<bool?>(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(
                      snapshot.data! ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    );
                  } else {
                    return Container();
                  }
                },
              )),
          IconButton(
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
              icon: FutureBuilder(
                future: controller?.getCameraInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(
                      Icons.cameraswitch_sharp,
                      color: Colors.white,
                    );
                  } else {
                    return Container();
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.deepPurple.shade400,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.7,
      ),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((barcode) async {
      await controller.pauseCamera();
      if (await canLaunch(barcode.code.toString())) {
        await launch(barcode.code.toString());
        controller.resumeCamera();
      } else {
        setState(() {
          this.barcode = barcode;
          Navigator.of(context)
              .push(MaterialPageRoute(
              builder: (context) =>
                  ThreeRender(url: barcode.code.toString())))
              .then((value) => controller.resumeCamera());
        });
        print(barcode.code);
      }
    });

    controller.stopCamera();
    controller.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
