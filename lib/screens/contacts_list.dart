import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/database/dao/contact_dao.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/screens/contact_form.dart';
import 'package:bytebank/screens/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class ContactsListState {
  const ContactsListState();
}

@immutable
class InitContactsListState extends ContactsListState {
  const InitContactsListState();
}

@immutable
class FatalErrorContactsListState extends ContactsListState {
  const FatalErrorContactsListState();
}

class LoadedContactsListState extends ContactsListState {
  final List<Contact> _contacts;

  LoadedContactsListState(this._contacts);
}

@immutable
class LoadingContactsListState extends ContactsListState {
  const LoadingContactsListState();
}

class ContactsListCubit extends Cubit<ContactsListState> {
  ContactsListCubit() : super(InitContactsListState());

  void reload(ContactDao dao) {
    emit(LoadingContactsListState());
    dao.findAll().then((contacts) => emit(LoadedContactsListState(contacts)));
  }
}

class ContactsListContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    final ContactDao dao = new ContactDao();
    return BlocProvider<ContactsListCubit>(
      create: (BuildContext context) {
        final cubit = ContactsListCubit();
        cubit.reload(dao);
        return cubit;
      },
      child: ContactsList(dao),
    );
  }
}

class ContactsList extends StatelessWidget {
  final ContactDao _dao;
  const ContactsList(this._dao);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Transfer'),
      ),
      body: BlocBuilder<ContactsListCubit, ContactsListState>(
        builder: (context, state) {
          if (state is InitContactsListState ||
              state is LoadingContactsListState) {
            return Progress();
          }
          if (state is LoadedContactsListState) {
            final List<Contact> contacts = state._contacts;
            return ListView.builder(
              itemBuilder: (context, index) {
                final Contact contact = contacts[index];
                return _ContactItem(
                  contact: contact,
                  onClick: () {
                    push(context, TransactionFormContainer(contact));
                  },
                );
              },
              itemCount: contacts.length,
            );
          }

          return Column(
            children: <Widget>[
              const Text('Unknown error was been detected '),
            ],
          );
        },
      ),
      floatingActionButton: buildAddContactButton(context),
    );
  }

  FloatingActionButton buildAddContactButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactForm(),
          ),
        );
        update(context);
      },
      child: Icon(
        Icons.add,
      ),
    );
  }

  void update(BuildContext context) {
    context.read<ContactsListCubit>().reload(_dao);
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function onClick;
  const _ContactItem({
    this.contact,
    @required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          contact.name,
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        subtitle: Text(
          contact.accountNumber.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
