import 'package:flutter/material.dart';
import 'package:shop_helper_flutter/managers/db_manager.dart';

import 'purchase.dart';

// contains all purchases for a particular day

// Provider package for state management https://pub.dev/packages/provider
class DailyPurchases with ChangeNotifier {
  final String _date;
  final List<Purchase> _purchasesList = [];
  Purchase _newPurchase;
  Purchase _removedPurchase;

  DailyPurchases(this._date) {
    _newPurchase =
        Purchase(name: "", date: _date, hint: "Purchase 1", currency: "\$");
  }

  String get date => _date;
  List<Purchase> get purchasesList => List.from(_purchasesList);
  Purchase get newPurchase => _newPurchase;

  // adding purchase by user
  void addNewPurchase() {
    _newPurchase.newProduct.setPrice(0.0);
    _newPurchase.newProduct.setQuantity(0);

    if (_newPurchase.name.isEmpty) _newPurchase.setName(_newPurchase.hint);
    for (final product in _newPurchase.productsList)
      if (product.title.isEmpty) product.setTitle("Product ${product.index}");

    _purchasesList.add(Purchase.from(_newPurchase));
    _newPurchase = Purchase(
      name: "",
      date: _date,
      hint: "Purchase ${_purchasesList.length + 1}",
      currency: "\$",
    );
    notifyListeners();
  }

  // add purchase from SQl table when launchung the app
  void addPurchaseFromTable(Purchase purchase) {
    _purchasesList.add(purchase);
    _newPurchase = Purchase(
      name: "",
      date: _date,
      hint: "Purchase ${_purchasesList.length + 1}",
      currency: "\$",
    );
  }

  void removePurchase({int index, Purchase purchase}) async {
    if (index == null) index = _purchasesList.indexOf(purchase);
    _removedPurchase = _purchasesList.removeAt(index);
    _removedPurchase.productsList.forEach((product) => product.image?.delete());
    await DBManager().deletePurchase(_removedPurchase.id);
    _newPurchase = Purchase(
      name: "",
      date: _date,
      hint: "Purchase ${_purchasesList.length + 1}",
      currency: "\$",
    );
    notifyListeners();
  }
 
  // cancel removing in case of missclick
  void undoRemoving(int index) async {
    _purchasesList.insert(index, Purchase.from(_removedPurchase));
    for (final product in _removedPurchase.productsList)
      await DBManager().addProduct(_removedPurchase, product);
    _newPurchase = Purchase(
      name: "",
      date: _date,
      hint: "Purchase ${_purchasesList.length + 1}",
      currency: "\$",
    );
    notifyListeners();
  }
}
