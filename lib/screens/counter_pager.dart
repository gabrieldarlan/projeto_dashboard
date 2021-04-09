import 'package:bytebank/components/container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Exemplo de contador utilizando bloc
//com duas variacoes
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

class CounterContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    //! não tems como saber quando devemos redesenhar o componente
    //! final state = context.read<CounterCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nosso contador'),
      ),
      body: Center(
        // ruim nao sabemos quando vai rebuildar
        // child: Text('$state',style: textTheme.headline2),

        // é notificado quando deve ser rebuildado
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, state) {
            return Text("$state", style: textTheme.headline2);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            //!Abordagem 1 de como acessar um bloc
            onPressed: () => context.read<CounterCubit>().increment(),
            //! Jeito antigo onPressed: () => context.bloc<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
