import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user.dart';
import 'pages/user_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fire base reed and write',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      home: const Myapphome(),
    );
  }
}

class Myapphome extends StatefulWidget {
  const Myapphome({super.key});

  @override
  State<Myapphome> createState() => _MyapphomeState();
}

class _MyapphomeState extends State<Myapphome> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios'),
        ),
        body: buildUsers(),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserPage(),
                ),
              );
            },
            ),
      );

  Widget buildUsers() => StreamBuilder<List<User>>(
      stream: readUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('hay erroe ${snapshot.error}');
        } else if (snapshot.hasData) {
          final users = snapshot.data!;
          return ListView(
            children: users.map(buildUser).toList(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator());
        }
      });

  // widget que nos muestra una especie de cuadro con la edad y titulo y un subtitulo
  Widget buildUser(User user) => ListTile(
        // quiero que se me muestre dentro de un circulo la edad
        leading: CircleAvatar(child: Text('${user.age}')),
        title: Text(user.name),
        // para mostrar fechas utilizamos toIso8601String()
        subtitle: Text(user.birthday.toIso8601String()),
      );

// esto sirve para extraer los archivos en un json de firebase
  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  Future<User?> readUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc('my-id');
    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
  }

  Future createUser({required String name}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();

    final json = {
      'id': docUser.id,
      'name': name,
      'age': 28,
      'birthday': DateTime(2022, 11, 24),
    };

    await docUser.set(json);
  }
}
