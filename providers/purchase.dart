import 'package:flutter/material.dart';
import 'package:shop_helper_flutter/providers/selector_provider.dart';
import 'package:shop_helper_flutter/providers/product.dart';
import 'package:shop_helper_flutter/managers/db_manager.dart';

class Purchase with ChangeNotifier {
  String _name;
  Product _newProduct = Product(title: "", quantity: 0, price: 0.0);
  String _hint = "";
  List<Product> _products = [];
  String _date;
  String _id;
  String _currency;
  bool _selected = false;

  Purchase({String name, String date, String id, String hint, String currency}) {
    _name = name;
    _date = date;
    _id = id == null ? DateTime.now().toString() : id;
    _hint = hint;
    _currency = currency;
  }

  Purchase.from(Purchase purchase) {
    _name = purchase._name;
    _newProduct = Product.copy(purchase._newProduct);
    _products = List.from(purchase._products);
    _date = purchase._date;
    _id = purchase._id;
    _currency = purchase._currency;
  }

  String get name => _name;
  Product get newProduct => _newProduct;
  List<Product> get productsList => List.from(_products);
  String get date => _date;
  String get id => _id;
  bool get isSelected => _selected;
  String get hint => _hint;
  String get currency => _currency;

  String get price {
    double price = 0.0;
    for (final product in _products) price += double.parse(product.sumFormatted);
     if (price - price.roundToDouble() == 0.0 || price == 0.0)
      return price.round().toString();
    else
      return price.toString();
  }

  void setName(String name) {
    _name = name;
    DBManager().setPurchaseName(_id, name);
  }

  void setCurrency(String currency){
    _currency = currency;
    DBManager().setCurrency(_id, currency);
    notifyListeners();
  }

  void addNewProduct() {
    final newProductHint = _newProduct.title.isEmpty
        ? "Product ${productsList.length + 1}"
        : _newProduct.title;

    int newProductIndex = _products.length + 1;
    _products.add(
      Product(
        hint: newProductHint,
        title: "",
        quantity: 1,
        price: double.parse(_newProduct.price),
        index: newProductIndex,
      ),
    );
    DBManager().addProduct(this, _products.last);
    notifyListeners();
  }

  void addProductFromTable(Product product) {
    int index = _products.length + 1;
    product.setIndex(index);
    _products.add(product);
  }

  Product removeProduct(int index) {
    final removedProduct = _products.removeAt(index);
    removedProduct.image?.delete();
    DBManager().deleteProduct(_id, removedProduct.id);
    notifyListeners();
    return removedProduct;
  }

  void select() {
    _selected = !_selected;
    _selected == true
        ? SelectorProvider().select()
        : SelectorProvider().undoSelection();
    notifyListeners();
  }
}
