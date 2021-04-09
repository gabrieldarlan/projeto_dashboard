import 'dart:async';

import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/components/transaction_auth_dialog.dart';
import 'package:bytebank/http/webclients/transaction_webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class TransactionFormtState {
  const TransactionFormtState();
}

@immutable
class ShowFormState extends TransactionFormtState {
  const ShowFormState();
}

@immutable
class FatalErrorTransactionFormState extends TransactionFormtState {
  const FatalErrorTransactionFormState();
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

  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionId = Uuid().v4();

  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormtState>(
        builder: (context, state) {
      if (state is ShowFormState) {
        return _BasicForm();
      }
      if (state is SendingState) {
        // return ProgressWindow();
      }
      if (state is SentState) {
        //TODO sera?
        Navigator.pop(context);
      }
      if (state is FatalErrorTransactionFormState) {
        //TODO tela de erro
      }

      //TODO tela de erro
      return Text('Erro');
    });
  }

  void _save(
    Transaction transactionCreated,
    String password,
    BuildContext context,
  ) async {
    Transaction transaction = await _send(
      transactionCreated,
      password,
      context,
    );

    _showSuccessfulMessage(transaction, context);
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

  Future<Transaction> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    //TODO fazer enviar
    // setState(() {
    //   _sending = true;
    // });
    final Transaction transaction =
        await _webClient.save(transactionCreated, password).catchError((e) {
      _showFailuredMessage(context, message: e.message);
    }, test: (e) => e is HttpException).catchError((e) {
      _showFailuredMessage(context,
          message: 'timeout submitting the transaction');
    }, test: (e) => e is TimeoutException).catchError((e) {
      _showFailuredMessage(context);
    }).whenComplete(() {
      //TODO completou
      // setState(() {
      //   _sending = false;
      // });
    });
    return transaction;
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
  @override
  Widget build(BuildContext context) {
    return  Text('teste');
    // Scaffold(
    //   appBar: AppBar(
    //     title: Text('New transaction'),
    //   ),
    //   body: SingleChildScrollView(
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           Visibility(
    //             visible: _sending,
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Progress(message: 'Sending...'),
    //             ),
    //           ),
    //           Text(
    //             _contact.name,
    //             style: TextStyle(
    //               fontSize: 24.0,
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 16.0),
    //             child: Text(
    //               _contact.accountNumber.toString(),
    //               style: TextStyle(
    //                 fontSize: 32.0,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 16.0),
    //             child: TextField(
    //               controller: _valueController,
    //               style: TextStyle(fontSize: 24.0),
    //               decoration: InputDecoration(
    //                 labelText: 'Value',
    //                 border: OutlineInputBorder(),
    //               ),
    //               keyboardType: TextInputType.numberWithOptions(decimal: true),
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 16.0),
    //             child: SizedBox(
    //               width: double.maxFinite,
    //               child: RaisedButton(
    //                 child: Text('Transfer'),
    //                 onPressed: () {
    //                   final double value =
    //                       double.tryParse(_valueController.text);
    //                   final transactionCreated = Transaction(
    //                     transactionId,
    //                     value,
    //                     _contact,
    //                   );
    //                   showDialog(
    //                     context: context,
    //                     builder: (contextDialog) {
    //                       return TransactionAuthDialog(
    //                         onConfirm: (String password) {
    //                           _save(transactionCreated, password, context);
    //                         },
    //                       );
    //                     },
    //                   );
    //                 },
    //               ),
    //             ),
    //           )
    //         ],
    //       ),
    //     ),,
    //   ),
    // );
  }
}
