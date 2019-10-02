import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop_helper_flutter/pages/image_view.dart';
import 'package:shop_helper_flutter/providers/product.dart';
import 'package:shop_helper_flutter/providers/purchase.dart';
import 'package:shop_helper_flutter/routes/transparent_route.dart';
import 'package:shop_helper_flutter/widgets/text_fields/price_field.dart';
import 'package:shop_helper_flutter/widgets/text_fields/quantity_field.dart';
import 'package:shop_helper_flutter/widgets/text_fields/sum_field.dart';
import 'package:shop_helper_flutter/widgets/text_fields/title_field.dart';


// UI element diplayed in editable animated list
class ProductCard extends StatelessWidget {
  final Function _delete;

  ProductCard(this._delete);

  // take photo from smartphone camera
  Future<void> _takePicture(Product product) async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      final croppedImage = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        ratioX: 1.0,
        ratioY: 1.0,
        maxWidth: 700,
        maxHeight: 700,
      );
      if (croppedImage != null) product.setImage(croppedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width;
    final cardHeight = cardWidth * 43 / 84;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      padding: const EdgeInsets.only(
        left: 18.0,
        top: 15.0,
        right: 15.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 0.4,
          color: Color(0xFFFFDBC5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 219, 197, 0.5),
            offset: Offset(0.0, 6.0),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: _buildCardContent(cardHeight, context),
    );
  }

  Column _buildCardContent(double cardHeight, BuildContext context) {
    final product = Provider.of<Product>(context);
    return Column(
      children: <Widget>[
        _buildTitleRow(cardHeight, context),
        Divider(
          height: 0.0,
          color: Color(0xFFFFDBC5),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              product.image == null
                  ? _buildImageIcon(cardHeight, context)
                  : _buildPictureSquare(cardHeight, context),
              Flexible(
                child: Container(
                  height: cardHeight / 1.85,
                  padding: const EdgeInsets.only(left: 42.0, top: 1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildPriceRow(cardHeight, context),
                      _buildQuantityRow(cardHeight, context),
                      _buildSumRow(cardHeight, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageIcon(double cardHeight, BuildContext context) {
    final product = Provider.of<Product>(context);
    return GestureDetector(
      onTap: () => _takePicture(product),
      child: Image.asset(
        'assets/image_icon.png',
        height: cardHeight / 1.95,
      ),
    );
  }

  Widget _buildPictureSquare(double cardHeight, BuildContext context) {
    final product = Provider.of<Product>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          TransparentRoute(
            builder: (context) => ImageView(
              product.image,
              () => _takePicture(product),
            ),
          ),
        );
      },
      child: Container(
        height: cardHeight / 1.95,
        width: cardHeight / 1.55,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Hero(
            tag: product.image,
            child: Image.file(
              product.image,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }

  Future _setBarCode(BuildContext context) async {
    final product = Provider.of<Product>(context);
    if (product.barcode != null) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _barcodeValue(product, context),
        ),
      );
    } else {
      try {
        product.setBarcode(await BarcodeScanner.scan());
      } on FormatException {}
    }
  }

  Widget _barcodeValue(Product product, BuildContext context) {
    return Container(
      width: 300.0,
      height: 110.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0, top: 8.0),
            child: Text(
              product.barcode.length <= 33
                  ? product.barcode
                  : product.barcode.substring(0, 29) + "...",
              style: TextStyle(
                  fontSize: 18.0, decoration: TextDecoration.underline),
            ),
          ),
          Divider(),
          FlatButton(
            padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
            child: Text(
              "Update",
              style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () async {
              try {
                product.setBarcode(await BarcodeScanner.scan());
              } on FormatException {}
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSumRow(double cardHeight, BuildContext context) {
    final purchase = Provider.of<Purchase>(context);
    return Row(
      children: <Widget>[
        Text(
          "TOTAL:",
          style: TextStyle(
            fontSize: cardHeight / 13.5,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(width: cardHeight / 13.5),
        Text(
          "${purchase.currency} ",
          style: TextStyle(fontSize: 15.0),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: SumField(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(double cardHeight, BuildContext context) {
    final product = Provider.of<Product>(context);
    final purchase = Provider.of<Purchase>(context);
    return Row(
      children: <Widget>[
        Container(
          width: cardHeight / 7.0,
          height: cardHeight / 7.0,
          margin: EdgeInsets.only(
            right: 15.0,
          ),
          child: MaterialButton(
            disabledColor: Color(0xFFFDE0D5).withOpacity(0.4),
            onPressed: product.quantity == 0
                ? null
                : () {
                    product.decQuantity();
                    purchase.notifyListeners();
                  },
            elevation: 0.0,
            padding: EdgeInsets.all(0.0),
            highlightElevation: 0.0,
            splashColor: Color(0xFFFFDBC5),
            highlightColor: Color(0xFFFFDBC5),
            shape: CircleBorder(),
            color: Color(0xFFFDE0D5),
            child: SvgPicture.asset(
              'assets/minus.svg',
              width: 7.5,
            ),
          ),
        ),
        Flexible(child: QuantityField()),
        Container(
          width: cardHeight / 7.0,
          height: cardHeight / 7.0,
          margin: EdgeInsets.only(left: 15.0),
          child: MaterialButton(
            onPressed: () {
              product.incQuantity();
              purchase.notifyListeners();
            },
            elevation: 0.0,
            padding: EdgeInsets.all(0.0),
            highlightElevation: 0.0,
            splashColor: Color(0xFFFFDBC5),
            highlightColor: Color(0xFFFFDBC5),
            shape: CircleBorder(),
            color: Color(0xFFFDE0D5),
            child: SvgPicture.asset(
              'assets/plus.svg',
              width: 11.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(double cardHeight, BuildContext context) {
    final purchase = Provider.of<Purchase>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Row(
            children: <Widget>[
              Text(
                "PRICE:",
                style: TextStyle(
                  fontSize: cardHeight / 13.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(width: cardHeight / 11.5),
              Text(
                "${purchase.currency} ",
                style: TextStyle(fontSize: 15.0),
              ),
            ],
          ),
        ),
        Flexible(
          child: PriceField(),
        ),
      ],
    );
  }

  Widget _buildTitleRow(double cardHeight, BuildContext context) {
    final product = Provider.of<Product>(context);
    return Row(
      children: <Widget>[
        Text(
          "${product.index}   ",
          style: TextStyle(
            color: Color(0xFFEFB0B0),
            fontSize: 18.0,
          ),
        ),
        Flexible(
          child: TitleField(),
        ),
        Container(
          width: 45.0,
          height: 40.0,
          child: MaterialButton(
            padding: EdgeInsets.all(0.0),
            splashColor: Color.fromRGBO(253, 224, 213, 0.4),
            highlightColor: Color.fromRGBO(253, 224, 213, 0.4),
            onPressed: () => _setBarCode(context),
            shape: CircleBorder(),
            child: product.barcode == null
                ? SvgPicture.asset('assets/barcode.svg')
                : Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
        ),
        Container(
          width: 45.0,
          height: 40.0,
          child: MaterialButton(
            padding: EdgeInsets.all(0.0),
            splashColor: Color.fromRGBO(253, 224, 213, 0.4),
            highlightColor: Color.fromRGBO(253, 224, 213, 0.4),
            onPressed: _delete,
            shape: CircleBorder(),
            child: SvgPicture.asset('assets/delete.svg'),
          ),
        ),
      ],
    );
  }
}
