import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsmart_users_en/screens/inner_screen/orders/orders_screen.dart';

class PaymentPage extends StatefulWidget {
  final Function function;
  const PaymentPage({
    super.key,
    required this.function,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  Future<void> _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      await widget.function();
      Navigator.pushReplacementNamed(context, OrdersScreenFree.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CreditCardWidget(
                  onCreditCardWidgetChange: (CreditCardBrand brand) {},
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  maxLength: 16,
                  decoration: InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter card number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      cardNumber = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Expiry Date'),
                  keyboardType: TextInputType.datetime,
                  maxLength: 5,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      expiryDate = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Card Holder Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      cardHolderName = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter CVV';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      cvvCode = value;
                    });
                  },
                  onTap: () {
                    setState(() {
                      isCvvFocused = true;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      isCvvFocused = false;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _submitPayment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Submit Payment'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
