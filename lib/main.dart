import 'package:bytebank/components/theme.dart';
import 'package:bytebank/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(ByteBankApp());

class LogObserver extends BlocObserver {
  @override
  void onChange(Cubit cubit, Change change) {
    print('${cubit.runtimeType} > $change');

    super.onChange(cubit, change);
  }
}

class ByteBankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // na pratica evitar log do genero, pois pode vazar informaçoes sensiveis para log
    Bloc.observer = LogObserver();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: bytebankTheme,
      home: DashboardContainer(),
    );
  }
}
