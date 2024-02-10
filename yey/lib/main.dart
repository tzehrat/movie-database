import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage()
        //MyHomePage(),
        );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController ratingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    CollectionReference moviesRef = _firestore.collection('movies');
    //var jokerRef = _firestore.collection('movies').doc('joker');
    var delihaRef = moviesRef.doc('deliha');

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Center(
            child: Column(
          children: [
            Text(
              'FİLMLER',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        )),
      ),
      body: Center(
          child: Column(children: [
        //  Text('${delihaRef.id}'),
        /* ElevatedButton(
              onPressed: () async {
                //  var response = await delihaRef.get();
                var response = await moviesRef.get();
                //dynamic map = response.data();
                //print(map['name']);
                //print(map['year']);
                //print(map['rating']);
                var list = response.docs;
                print(list[2].data());
              },
              child: Text('get wuerysnapshot'))*/
        StreamBuilder<QuerySnapshot>(
            stream: moviesRef.snapshots(),
            builder: (context, AsyncSnapshot asyncSnapshot) {
              if (asyncSnapshot.hasError) {
                return Center(
                  child: Text('hata'),
                );
              } else {
                if (asyncSnapshot.hasData) {
                  List<DocumentSnapshot> listOfDocumentSnapshot =
                      asyncSnapshot.data.docs;
                  return Flexible(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listOfDocumentSnapshot.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await listOfDocumentSnapshot[index]
                                      .reference
                                      .delete();
                                },
                              ),
                              title: Text(
                                  '${(listOfDocumentSnapshot[index].data() as Map)['name']}',
                                  style: TextStyle(fontSize: 23)),
                              subtitle: Text(
                                  '${(listOfDocumentSnapshot[index].data() as Map)['rating']}',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          );

                          /*Text(
                    '${asyncSnapshot.data.data()}',
                    style: TextStyle(fontSize: 23),
                  );*/
                        }),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }
            }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 50),
          child: Form(
              child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Film adını yazınız.'),
              ),
              TextFormField(
                controller: yearController,
                decoration: InputDecoration(hintText: 'Film yılını giriniz.'),
              ),
              TextFormField(
                controller: ratingController,
                decoration: InputDecoration(hintText: 'Filmin puanını giriniz'),
              )
            ],
          )),
        )
      ])),
      floatingActionButton: FloatingActionButton(
          child: Text('ekle'),
          onPressed: () async {
            print(nameController.text);
            print(yearController.text);
            print(ratingController.text);
            Map<String, dynamic> movieData = {
              'name': nameController.text,
              'year': yearController.text,
              'rating': ratingController.text,
            };

            await moviesRef.doc(nameController.text).set(movieData);
            //    await moviesRef.doc(nameController.text).update({'rating': 23});
          }),
    );
  }
}
