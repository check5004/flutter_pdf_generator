import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:printing/printing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey _printKey = GlobalKey();

  Future<void> _printDocument() async {
    print('step0 - printDocument');
    final pdf = pw.Document();

    final image = await _capturePng();

    print('step5 - addPage');
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(image)),
          );
        }));

    print('step6 - save');
    final output = await getTemporaryDirectory();
    print('step7 - save');
    final file = File("${output.path}/example.pdf");
    print('step8 - save');
    await file.writeAsBytes(await pdf.save());

    // PDFをプレビューするには、以下の行のコメントを外します。
    print('step9 - save');
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<Uint8List> _capturePng() async {
    try {
      print('step1 - capturePng');
      RenderRepaintBoundary boundary =
          _printKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      if (boundary == null) {
        throw Exception('RenderRepaintBoundary is null');
      }
      print('step2 - toImage');
      final image = await boundary.toImage(pixelRatio: 2.0);
      print('step3 - toByteData');
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      print('step4 - asUint8List');
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print(e);
      return Uint8List(0); // 空のUint8Listを返す
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter PDF Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            RepaintBoundary(
              key: _printKey,
              child: Container(
                color: Colors.white,
                height: 842, // A4 height
                width: 595, // A4 width
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(hintText: 'Enter some text'),
                    ),
                    SizedBox(height: 20),
                    CustomPaint(
                      size: Size(200, 200),
                      painter: MyCustomPainter(),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _printDocument,
              child: Text('Print Document'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5;

    // Draw a circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, paint);

    // Draw a rectangle
    canvas.drawRect(Rect.fromLTWH(50, 50, 100, 100), paint);

    // ... 他にも必要な図形を描画する
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
