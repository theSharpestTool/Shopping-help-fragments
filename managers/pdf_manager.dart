import 'dart:ui';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class PDFManager {
  static final PDFManager _singleton = PDFManager._internal();
  factory PDFManager() {
    return _singleton;
  }
  PDFManager._internal();

  Font _ttf;
  Document _pdf;

  Future<List<int>> sendPDF(List<Map<String, dynamic>> purchases) async {
    _pdf = Document();
    ByteData data =
        await rootBundle.load("fonts/SF-UI/SF-UI-Display-Regular.ttf");
    _ttf = Font.ttf(data);

    _pdf.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 20.0,
          marginRight: 20.0,
          marginTop: 30.0,
          marginBottom: 30.0,
        ),
        crossAxisAlignment: CrossAxisAlignment.start,
        build: (Context context) => _buildPurchasesList(purchases),
      ),
    );
    final bytes = _pdf.save(); // <- locks ui
    return bytes;
  }

  List<Widget> _buildPurchasesList(List<Map<String, dynamic>> purchases) {
    final String date = purchases.first['date'];
    List<Widget> widgetsList = [
      _buildDateRow(date),
      SizedBox(height: 23.0),
    ];

    for (final purchase in purchases) {
      widgetsList
        ..add(_buildPurchaseName(purchase['name']))
        ..add(SizedBox(height: 10.0))
        ..add(_buildPurchaseTable(purchase['products'], purchase['currency']))
        ..add(SizedBox(height: 10.0))
        ..add(_buildSumRow(purchase['total'], purchase['currency']))
        ..add(SizedBox(height: 10.0));
    }

    return widgetsList;
  }

  Row _buildSumRow(String sum, String currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "TOTAL: $currency $sum",
          style: TextStyle(
            fontSize: 17.0,
            font: _ttf,
          ),
        ),
        SizedBox(width: 70.0),
      ],
    );
  }

  Table _buildPurchaseTable(
      List<Map<String, dynamic>> products, String currency) {
    final List<TableRow> productRows = [_buildTopRow()];

    for (int i = 0; i < products.length; i++) {
      int index = i + 1;
      productRows.add(
        _buildProductRow(
          products[i],
          index.toString(),
          currency,
        ),
      );
    }

    return Table(
      border: TableBorder(
        color: PdfColors.black,
        width: 0.5,
        left: false,
        right: false,
      ),
      children: productRows,
    );
  }

  Text _buildPurchaseName(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.0,
        font: _ttf,
      ),
    );
  }

  Row _buildDateRow(String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          date,
          style: TextStyle(
            fontSize: 25.0,
            font: _ttf,
          ),
        ),
      ],
    );
  }

  TableRow _buildProductRow(
      Map<String, dynamic> product, String index, String currency) {
    return TableRow(
      children: [
        _buildCell(index),
        _buildCell(product['title']),
        _buildCell(product['barcode'] ?? "No barcode"),
        _photoSquare(product['photo']),
        _buildCell("$currency ${product['price']}"),
        _buildCell("${product['quantity']}"),
        _buildCell("$currency ${product['sum']}"),
        _buildCell(""),
      ],
    );
  }

  Container _buildCell(String value) {
    return Container(
      height: 70.0,
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 13.0,
            font: _ttf,
          ),
        ),
      ),
    );
  }

  Widget _photoSquare(List<int> bytes) {
    Image imageWidget;
    if (bytes != null) {
      final image = img.decodeImage(bytes);
      final imagePdf = PdfImage(
        _pdf.document,
        image: image.data.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
      imageWidget = Image(imagePdf, fit: BoxFit.cover);
    }

    return Container(
      width: 35.0,
      height: 60.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: bytes == null
          ? Center(
              child: Text(
                "No Photo",
                style: TextStyle(font: _ttf),
              ),
            )
          : ClipRRect(
              horizontalRadius: 10.0,
              verticalRadius: 10.0,
              child: imageWidget,
            ),
    );
  }

  TableRow _buildTopRow() {
    return TableRow(
      children: [
        SizedBox(
          width: 23.0,
          child: _buildTopCell("N"),
        ),
        _buildTopCell("PRODUCT"),
        _buildTopCell("BAR-CODE"),
        _buildTopCell("PHOTO"),
        _buildTopCell("PRICE"),
        _buildTopCell("Q-TY"),
        _buildTopCell("TOTAL"),
        _buildTopCell("NOTES"),
      ],
    );
  }

  Container _buildTopCell(String text) {
    return Container(
      height: 23.0,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10.0,
            font: _ttf,
          ),
        ),
      ),
    );
  }
}
