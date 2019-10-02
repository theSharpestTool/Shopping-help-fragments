import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop_helper_flutter/providers/purchase.dart';

class PurchaseBar extends StatefulWidget {
  final Function _callDropdown;

  PurchaseBar(this._callDropdown);

  @override
  _PurchaseBarState createState() => _PurchaseBarState();
}

class _PurchaseBarState extends State<PurchaseBar> {
  TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.0),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 3.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(25.0),
          bottomRight: const Radius.circular(25.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFB0B0),
            Color(0xFFFFDBC5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 219, 197, 0.5),
            blurRadius: 16.0,
            offset: Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                _buildPurchaseTitle(context),
                _buidBackButton(),
              ],
            ),
            _buildSumCurrencyRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildSumCurrencyRow() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 7.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSumLabel(),
          _buildCurrencyButton(),
        ],
      ),
    );
  }

  Container _buildCurrencyButton() {
    return Container(
      height: 30.0,
      width: 30.0,
      margin: EdgeInsets.only(
        left: 10.0,
      ),
      child: MaterialButton(
        padding: EdgeInsets.all(5.0),
        onPressed: widget._callDropdown,
        elevation: 0.0,
        highlightElevation: 0.0,
        splashColor: Color(0xFFFFDBC5),
        highlightColor: Color(0xFFFFDBC5),
        shape: CircleBorder(),
        color: Color.fromRGBO(255, 255, 255, 0.32),
        child: SvgPicture.asset(
          'assets/down-arrow.svg',
          height: 12.0,
        ),
      ),
    );
  }

  Row _buildSumLabel() {
    Purchase purchase = Provider.of<Purchase>(context);
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 1.5),
          child: Text(
            "Total: ",
            style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w200),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 1.5, left: 1.0),
          child: Text(
            '${purchase.currency} ',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 3.5,
          ),
          child: Text(
            "${purchase.price}",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseTitle(BuildContext context) {
    Purchase purchase = Provider.of<Purchase>(context);
    _textController.text = purchase.name;
    _textController.selection =
        TextSelection.collapsed(offset: _textController.text.length);
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10.0),
        width: 118.0,
        child: TextField(
          controller: _textController,
          onChanged: (name) => purchase.setName(name),
          cursorColor: Color(0xFF999999),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 23.0,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.32),
              ),
            ),
            hintText: purchase.hint,
            hintStyle: TextStyle(
                color: Color(0xFF999999),
                fontSize: 23.0,
                fontWeight: FontWeight.w300),
            contentPadding: EdgeInsets.all(0.0),
          ),
        ),
      ),
    );
  }

  Widget _buidBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        splashColor: Color(0xFFFFDBC5),
        highlightColor: Color(0xFFFFDBC5),
        padding: EdgeInsets.only(left: 18.0, right: 12.0),
        icon: SvgPicture.asset('assets/left-arrow.svg'),
        onPressed: Navigator.of(context).pop,
      ),
    );
  }
}
