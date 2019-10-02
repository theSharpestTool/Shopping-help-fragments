import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop_helper_flutter/providers/purchase.dart';
import 'package:shop_helper_flutter/widgets/products_page/product_card.dart';
import 'package:shop_helper_flutter/widgets/products_page/purchase_bar.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _showDropdown = false;
  Purchase _purchase;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _callDropdown() => setState(() => _showDropdown = !_showDropdown);

  @override
  Widget build(BuildContext context) {
    _purchase = Provider.of<Purchase>(context);
    return Scaffold(
      floatingActionButton: _buildAddButton(),
      appBar: PreferredSize(
        child: PurchaseBar(_callDropdown),
        preferredSize: new Size(
          MediaQuery.of(context).size.width,
          150.0,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_showDropdown) _callDropdown();
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              _buildCardsList(),
              _buildCurrenySelector(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      backgroundColor: Colors.white,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFB1B1),
              Color(0xFFFFDBC5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0.0, 6.0),
              blurRadius: 12.0,
              color: Color.fromRGBO(255, 219, 197, 0.5),
            ),
          ],
        ),
        child: MaterialButton(
          height: 80.0,
          splashColor: Color(0xFFFFDBC5),
          highlightColor: Color(0xFFFFDBC5),
          shape: CircleBorder(),
          onPressed: _addProduct,
          child: SvgPicture.asset('assets/add_button.svg'),
        ),
      ),
      onPressed: () {},
    );
  }

  Widget _buildCardsList() {
    return AnimatedList(
      key: _listKey,
      itemBuilder: (context, index, animation) {
        return _animatedCard(animation, index);
      },
      initialItemCount: _purchase.productsList.length,
    );
  }

  Widget _animatedCard(Animation<double> animation, int index) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _purchase.productsList[index]),
          ChangeNotifierProvider.value(value: _purchase),
        ],
        child: ProductCard(() => _deleteProduct(index)),
      ),
    );
  }

  void _addProduct() {
    _purchase.addNewProduct();
    int index = _purchase.productsList.length - 1;
    _listKey.currentState?.insertItem(index);
  }

  void _deleteProduct(int index) {
    final removedPurchase = _purchase.removeProduct(index);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child:MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: removedPurchase),
          ChangeNotifierProvider.value(value: _purchase),
        ],
        child: ProductCard(() => _deleteProduct(index)),
      ),
      );
    };
    _listKey.currentState.removeItem(index, builder);
  }

  AnimatedPositioned _buildCurrenySelector(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      top: _showDropdown ? 0.0 : -162.0,
      right: MediaQuery.of(context).size.width/2 - 50,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 0.4,
            color: Color(0xFFFFDBC5),
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(255, 219, 197, 0.5),
              offset: Offset(0.0, 4.0),
              blurRadius: 8.0,
            ),
          ],
        ),
        width: 100.0,
        height: 150.0,
        child: Column(
          children: <Widget>[
            _buildCurrencyListTile('€ - EUR'),
            _buildCurrencyListTile('₴ - UAH'),
            _buildCurrencyListTile('£ - GBP'),
            _buildCurrencyListTile('\$ - USD'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyListTile(String currency) {
    return SizedBox(
      width: double.infinity,
      height: 37.0,
      child: FlatButton(
        splashColor: Color(0xFFFFF5EF),
        highlightColor: Color(0xFFFFF5EF),
        onPressed: (){
          _purchase.setCurrency(currency[0]);
          _callDropdown();
        },
        child: Text(
          currency,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
