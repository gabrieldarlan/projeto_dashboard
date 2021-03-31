import 'package:bytebank/models/contact.dart';
import 'package:flutter/material.dart';
//! CONTINUAR DA AULA 06 CAPITULO 2
class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Full name',
              ),
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account number',
                ),
                style: TextStyle(fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    final String name = _nameController.text;
                    final int accountNumber =
                        int.tryParse(_accountController.text);
                    final Contact newContact = Contact(name, accountNumber);
                    Navigator.pop(context, newContact);
                  },
                  child: Text('Create'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
