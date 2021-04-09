import 'dart:async';

import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/error.dart';
import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/http/webclients/transaction_webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../components/progress.dart';
import '../components/transaction_auth_dialog.dart';

@immutable
abstract class TransactionFormtState {
  const TransactionFormtState();
}

@immutable
class ShowFormState extends TransactionFormtState {
  const ShowFormState();
}

@immutable
class FatalErrorFormState extends TransactionFormtState {
  final String _message;
  const FatalErrorFormState(this._message);
}

class SentState extends TransactionFormtState {
  const SentState();
}

@immutable
class SendingState extends TransactionFormtState {
  const SendingState();
}

class TransactionFormCubit extends Cubit<TransactionFormtState> {
  TransactionFormCubit() : super(ShowFormState());

  void save(
    Transaction transactionCreated,
    String password,
    BuildContext context,
  ) async {
    emit(SendingState());
    await _send(
      transactionCreated,
      password,
      context,
    );
  }

  _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    await TransactionWebClient()
        .save(transactionCreated, password)
        .then((transaction) => SentState())
        .catchError((e) {
      emit(FatalErrorFormState(e.message));
    }, test: (e) => e is HttpException).catchError((e) {
      emit(FatalErrorFormState('timeout submitting the transaction'));
    }, test: (e) => e is TimeoutException).catchError((e) {
      emit(FatalErrorFormState(e.message));
    });
  }
}

class TransactionFormContainer extends BlocContainer {
  final Contact _contact;
  TransactionFormContainer(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (context) {
        return TransactionFormCubit();
      },
      child: TransactionFormStateless(_contact),
    );
  }
}

// ignore: must_be_immutable
class TransactionFormStateless extends StatelessWidget {
  final Contact _contact;
  TransactionFormStateless(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormtState>(
        builder: (context, state) {
      if (state is ShowFormState) {
        return _BasicForm(_contact);
      }
      if (state is SendingState) {
        return ProgressView();
      }
      if (state is SentState) {
        //TODO CONTINUAR DA PARTE QUE ELE VAI EXPLICAR
        //TODO COMO QUE TRATA O SENTSTATE
        Navigator.pop(context);
      }
      if (state is FatalErrorFormState) {
        return ErrorView(state._message);
      }
      return ErrorView('Unknown error');
    });
  }

  Future _showSuccessfulMessage(
      Transaction transaction, BuildContext context) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('successful transaction');
          });
      Navigator.pop(context);
    }
  }

  void _showFailuredMessage(BuildContext context,
      {String message = 'Unknown error'}) {
    showDialog(
      context: context,
      builder: (contextDialog) {
        return FailureDialog(message);
      },
    );
  }
}

class _BasicForm extends StatelessWidget {
  final TextEditingController _valueController = TextEditingController();

  final String transactionId = Uuid().v4();

  final Contact _contact;
  _BasicForm(this._contact);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text('Transfer'),
                    onPressed: () {
                      final double value =
                          double.tryParse(_valueController.text);
                      final transactionCreated = Transaction(
                        transactionId,
                        value,
                        _contact,
                      );
                      showDialog(
                        context: context,
                        builder: (contextDialog) {
                          return TransactionAuthDialog(
                            onConfirm: (String password) {
                              BlocProvider.of<TransactionFormCubit>(context)
                                  .save(transactionCreated, password, context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
