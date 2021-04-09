import 'package:bytebank/components/container.dart';
import 'package:bytebank/models/name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    return NameView();
  }
}

class NameView extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // agora não tem problema essa abordagem
    // pois não vamos rebuidar o componente
    _nameController.text = context.watch<NameCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              style: TextStyle(
                fontSize: 24,
              ),
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Desired name',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.maxFinite,
                child: RaisedButton(
                  child: Text('Change'),
                  onPressed: () {
                    final name = _nameController.text;
                    context.read<NameCubit>().change(name);
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
