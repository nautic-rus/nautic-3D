import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nautic_viewer/data/api/zipobject_services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/api/documents_services.dart';
import '../../internal/localfiles/local_files.dart';
import '../datascreens/data_from_scanner.dart';

class QrReader extends StatefulWidget {
  QrReader({Key? key, required this.futureDocs, required this.connectionState})
      : super(key: key);

  List<DocData> futureDocs;
  String connectionState;

  @override
  State<QrReader> createState() => _QrReaderState();
}

class _QrReaderState extends State<QrReader> {
  Barcode? barcode;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrViewOpened = false;

  var mdq;
  late double width;
  late double height;

  var brightness;

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
    mdq = MediaQuery.of(context).size;
    if (mdq.height > mdq.width) {
      height = mdq.height;
      width = mdq.width;
    } else {
      width = mdq.height;
      height = mdq.width;
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        buildQrView(context),
        Positioned(
          child: buildControlButtons(),
          bottom: 40,
        )
      ],
    );
  }

  Widget buildControlButtons() {
    brightness = SchedulerBinding.instance.window.platformBrightness;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: brightness == Brightness.dark
            ? Color(0xFF67CAD7)
            : Color(0xFF2C298A),
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
                      snapshot.data! ?
                      Icons.flash_on : Icons.flash_off,
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

  Widget buildQrView(BuildContext
  context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Color(0xFF67CAD7),
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 15,
        cutOutSize: width * 0.7,
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
        setState(() async {
          this.barcode = barcode;
          if (validateUrl(barcode.code.toString())) {
            print("barcode ${barcode.code.toString()}");
            saveLastScanUrl(barcode.code.toString());
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => Document(
                          data: getData(barcode.code.toString()),
                          futureDocs: widget.futureDocs,
                          connectionState: widget.connectionState,
                        )))
                .then((value) => controller.resumeCamera());
          } else {
            await _dialogBuilder(context);
            controller.resumeCamera();
          }
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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'This QR code is not valid',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
