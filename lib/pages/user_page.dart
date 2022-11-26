import 'package:appchat2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController controllerName;
  late TextEditingController controllerAge;
  late TextEditingController controllerDate;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController();
    controllerAge = TextEditingController();
    controllerDate = TextEditingController();
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerAge.dispose();
    controllerDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('agregar usuario'),
        ),
        body: Form(
            key: formKey,
            child: ListView(
              padding:const EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  controller: controllerName,
                  decoration: decoration('nombre'),
                  validator: (text) =>
                      text != null && text.isEmpty ? 'entrada no valida' : null,
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  controller: controllerAge,
                  decoration: decoration('Edad'),
                  validator: (text) =>
                      text != null && int.tryParse(text) == null
                          ? 'entrada no valida'
                          : null,
                ),
                const SizedBox(
                  height: 24,
                ),

                DateTimeField(
                  controller: controllerDate,
                  decoration: decoration('fecha de nacimiento'),
                  validator: (datetime) =>
                      datetime == null ? 'entrada no valida' : null,
                  format: DateFormat('yyyy-MM-dd'),
                  onShowPicker: (context, currentValue) => showDatePicker(
                      context: context,
                      firstDate: DateTime(1950),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100)),
                ),
                const SizedBox(
                  height: 32,
                ),

                ElevatedButton(
                    onPressed: () {
                      final isValid = formKey.currentState!.validate();
                      if (isValid) {
                        final user = User(
                            name: controllerName.text,
                            age: int.parse(controllerAge.text),
                            birthday: DateTime.parse(controllerDate.text),);

                        createUser(user);

                        final snackBar = SnackBar(
                          backgroundColor: Colors.amber,
                          content: Text(
                              '${controllerName.text} se agrego a firebase',
                              style: const TextStyle(fontSize: 24)),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('enviar'))
              ],
            )),
      );

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );
  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id;
    final json = user.toJson();
    await docUser.set(json);
  }
}
