import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_helper_flutter/managers/db_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


class Product with ChangeNotifier {
  String _id;
  int _quantity;
  double _price;
  double _customSum;
  String _customSumString;
  String _title;
  String _hint;
  File _imageFile;
  String _barcode;
  bool _incDecButtonPressed = false;
  int _index;

  Product({
    @required String title,
    @required int quantity,
    @required double price,
    String hint,
    double sum,
    String id,
    String image,
    String barcode,
    int index,
  }) {
    _title = title;
    _quantity = quantity;
    _price = price;
    _hint = hint;
    _customSumString = (price * quantity).toString();
    if (sum != price * quantity) {
      _customSum = sum;
      _customSumString = sum.toString();
    }
    _id = id == null ? DateTime.now().toString() : id;
    _imageFile = image == null ? null : File(image);
    _barcode = barcode;
    _index = index;
  }

  Product.copy(Product product) {
    this._title = product._title;
    this._quantity = product._quantity;
    this._price = product._price;
    this._imageFile = product._imageFile;
    this._customSum = product._customSum;
    this._customSumString = product._customSumString;
    this._id = DateTime.now().toString();
    this._barcode = product._barcode;
    this._index = product._index;
  }

  int get quantity => _quantity;
  String get price {
    if (_price - _price.roundToDouble() == 0.0 || _price == 0.0)
      return _price.round().toString();
    else
      return _price.toString();
  }

  String get sumFormatted {
    final sum = _customSum == null ? _quantity * _price : _customSum;
    _customSumString = sum.toString();
    if (sum - sum.roundToDouble() == 0.0 || sum == 0.0) {
      _customSumString = sum.round().toString();
      return _customSumString;
    } else {
      _customSumString = sum.toString();
      return _customSumString;
    }
  }

  String get hint => _hint;
  String get sumString {
    if (_customSum == null) {
      final sum = _quantity * _price;
      if (sum - sum.roundToDouble() == 0.0 || sum == 0.0) {
        return sum.round().toString();
      } else {
        return sum.toString();
      }
    } else
      return _customSumString;
  }

  bool get customSum => _customSum != null;
  bool get incDecButtonPressed => _incDecButtonPressed;
  void setIncDecButtonPressed(bool presssed) => _incDecButtonPressed = presssed;
  String get title => _title;
  File get image => _imageFile;
  String get id => _id;
  String get barcode =>
      (_barcode != null && _barcode.isEmpty) ? null : _barcode;
  int get index => _index;

  void setIndex(int index) => _index = index;

  void setTitle(String title) {
    _title = title;
    DBManager().setProductTitle(_id, title);
    notifyListeners();
  }

  void incQuantity() {
    _incDecButtonPressed = true;
    setQuantity(_quantity + 1);
  }

  void decQuantity() {
    _incDecButtonPressed = true;
    setQuantity(_quantity - 1);
  }

  void setQuantity(int quantity) {
    if (quantity == _quantity) return;
    _quantity = quantity;
    _customSum = null;
    DBManager().setQuantity(_id, quantity.toString());
    DBManager().setSum(_id, sumFormatted.toString());
    notifyListeners();
  }

  void setPrice(double price) {
    if (price == _price) return;
    _price = price;
    _customSum = null;
    DBManager().setPrice(_id, price.toString());
    DBManager().setSum(_id, sumFormatted.toString());
    notifyListeners();
  }

  void setCustomSum(String customSum) {
    _customSum = double.parse(customSum);
    _customSumString = customSum;
    DBManager().setSum(_id, customSum.toString());
    notifyListeners();
  }

  void setImage(File image) async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final docPath = docDirectory.path;
    final imageName = path.basename(image.path);
    await _imageFile?.delete();
    _imageFile = await image.copy('$docPath/$imageName');
    await image.delete();
    DBManager().setImage(_id, _imageFile.path);
    notifyListeners();
  }

  void setBarcode(String barcode) {
    _barcode = barcode;
    DBManager().setBarcode(_id, barcode);
    notifyListeners();
  }
}
