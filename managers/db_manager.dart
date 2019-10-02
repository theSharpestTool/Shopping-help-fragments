import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:shop_helper_flutter/providers/purchase.dart';
import 'package:shop_helper_flutter/providers/product.dart';
import 'package:shop_helper_flutter/providers/daily_purchases.dart';
import 'package:intl/intl.dart';

class DBManager {
  static final DBManager _singleton = DBManager._internal();
  factory DBManager() => _singleton;
  DBManager._internal();
  Database db;

  Future<void> init() async {
    final databasesPath = await sql.getDatabasesPath();
    final purchasesDBpath = path.join(databasesPath, "purchases.db");
    db = await sql.openDatabase(
      purchasesDBpath,
      onCreate: (db, version) {
        print("creating db");
        db.execute(
            'CREATE TABLE purchases(id TEXT PRIMARY KEY, name TEXT, date TEXT, currency TEXT)');
        db.execute(
            'CREATE TABLE products(id TEXT PRIMARY KEY, purchase_id TEXT, title TEXT, '
            'price TEXT, quantity TEXT, sum TEXT, currency TEXT, photo TEXT, barcode TEXT, '
            'FOREIGN KEY(purchase_id) REFERENCES purchases(id))');
      },
      version: 1,
    );
  }

  Future<void> addProduct(Purchase purchase, Product product) async {
    final purchasesCounter = sql.Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM purchases WHERE id = ?", [purchase.id]));

    if (purchasesCounter == 0)
      db.insert(
        'purchases',
        {
          'id': purchase.id,
          'name': purchase.name,
          'date': purchase.date,
          'currency': purchase.currency,
        },
      );

    db.insert('products', {
      'id': product.id,
      'purchase_id': purchase.id,
      'title': product.title,
      'price': product.price.toString(),
      'quantity': product.quantity.toString(),
      'sum': product.sumFormatted.toString(),
      'photo': product.image == null ? null : product.image.path,
      'barcode': product.barcode,
    });

    await printTable("purchases");
  }

  Future<void> deleteProduct(String purchaseId, String productId) async {
    db.delete('products', where: 'id = ?', whereArgs: [productId]);
    final productsCounter = sql.Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM products WHERE purchase_id = ?', [purchaseId]));
    if (productsCounter == 0)
      db.delete('purchases', where: 'id = ?', whereArgs: [purchaseId]);
  }

  Future<void> deletePurchase(String purchaseId) async {
    db.delete('products', where: 'purchase_id = ?', whereArgs: [purchaseId]);
    db.delete('purchases', where: 'id = ?', whereArgs: [purchaseId]);
  }

  Future<Map<DateTime, DailyPurchases>> fetchData() async {
    printTable('purchases');
    printTable('products');

    Map<String, Purchase> purchasesMap = {};
    final purchasesTable = await db.query('purchases');
    for (final purchase in purchasesTable) {
      purchasesMap[purchase['id']] = Purchase(
        name: purchase['name'],
        date: purchase['date'],
        id: purchase['id'],
        currency: purchase['currency'],
      );
    }

    final productsTable = await db.query('products');
    for (final product in productsTable) {
      assert(purchasesMap[product['purchase_id']] != null);
      purchasesMap[product['purchase_id']].addProductFromTable(
        Product(
          title: product['title'],
          quantity: int.parse(product['quantity']),
          price: double.parse(product['price']),
          sum: double.parse(product['sum']),
          id: product['id'],
          image: product['photo'],
          barcode: product['barcode'],
        ),
      );
    }

    Map<DateTime, DailyPurchases> dailyPurchases = {};
    purchasesMap.forEach((_, purchase) {
      final date = DateFormat.yMMMEd().parse(purchase.date);
      if (dailyPurchases[date] == null)
        dailyPurchases[date] = DailyPurchases(purchase.date);
      dailyPurchases[date].addPurchaseFromTable(purchase);
    });

    return dailyPurchases;
  }

  Future<void> setPurchaseName(String purchaseId, String purchaseName) async {
    db.rawUpdate("UPDATE purchases SET name = ? WHERE id = ?",
        [purchaseName, purchaseId]);
  }

  Future<void> setProductTitle(String productId, String title) async {
    db.rawUpdate(
        "UPDATE products SET title = ? WHERE id = ?", [title, productId]);
  }

  Future<void> setImage(String productId, String image) async {
    db.rawUpdate(
        "UPDATE products SET photo = ? WHERE id = ?", [image, productId]);
  }

  Future<void> setQuantity(String productId, String quantity) async {
    db.rawUpdate(
        "UPDATE products SET quantity = ? WHERE id = ?", [quantity, productId]);
  }

  Future<void> setPrice(String productId, String price) async {
    db.rawUpdate(
        "UPDATE products SET price = ? WHERE id = ?", [price, productId]);
  }

  Future<void> setSum(String productId, String sum) async {
    db.rawUpdate("UPDATE products SET sum = ? WHERE id = ?", [sum, productId]);
  }

  Future<void> setBarcode(String productId, String barcode) async {
    db.rawUpdate(
        "UPDATE products SET barcode = ? WHERE id = ?", [barcode, productId]);
  }

  Future<void> setCurrency(String purchaseId, String purchaseCurrency) async {
    db.rawUpdate("UPDATE purchases SET currency = ? WHERE id = ?",
        [purchaseCurrency, purchaseId]);
  }

  Future<void> printTable(String table) async {
    final data = await db.query(table);
    print(data);
  }

  Future<void> deleteAllTables() async {
    db.delete('purchases');
    db.delete('products');
  }
}
