import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/smart_device_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Référence à la base de données Firebase
  late DatabaseReference? dbRef;
  bool isToggled = false;
  var temp; // Température récupérée depuis Firebase
  var humidity; // Humidité récupérée depuis Firebase
  bool? boutonValue; // Variable pour stocker la valeur actuelle du bouton

  @override
  void initState() {
    super.initState();
    // Initialisation de la référence à la base de données Firebase
    dbRef = FirebaseDatabase.instance.ref();
    // Appel des fonctions pour charger les données et la valeur du bouton
    dataChange();
    getBoutonValue();
  }

  // Fonction pour écouter les changements de données depuis Firebase
  dataChange() {
    dbRef?.onValue.listen((event) {
      setState(() {
        // Récupération de la température depuis Firebase
        temp = event.snapshot.child("temperature").value;
        // Récupération de l'humidité depuis Firebase
        humidity = event.snapshot.child("humidity").value;
      });
      print("Données FIREBASE = $temp ");
    });
  }

  // Fonction pour récupérer la valeur actuelle du bouton dans Firebase
  Future<void> getBoutonValue() async {
    try {
      final snapshot = await dbRef?.child('bouton').get();
      if (snapshot != null && snapshot.exists) {
        setState(() {
          // Stocker la valeur actuelle du bouton
          boutonValue = snapshot.value as bool;
          // Synchroniser l'état du bouton dans l'application avec Firebase
          isToggled = boutonValue!;
        });
        print("Valeur actuelle du bouton: $boutonValue");
      }
    } catch (error) {
      print("Erreur lors de la récupération de la valeur du bouton: $error");
    }
  }

  // Fonction pour envoyer l'état du bouton toggle à Firebase
  sendToggleStateToFirebase(bool state) {
    dbRef?.child('bouton').set(state).then((_) {
      print("L'état du bouton a été mis à jour dans Firebase: $state");
    }).catchError((error) {
      print("Erreur lors de l'envoi des données à Firebase: $error");
    });
  }

  final double horizontalPadding = 30;
  final double verticalPadding = 10;

  // Liste des appareils intelligents
  List mySmartDevices = [
    ["Smart Light", "assets/light.svg", false],
    ["Smart AC", "assets/aircondition.svg", false],
    ["Smart TV", "assets/tv.svg", false],
    ["Smart Fan", "assets/fan.svg", false],
  ];

  // Fonction pour mettre à jour l'état d'alimentation d'un appareil
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre d'application personnalisée
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  "assets/menu.png",
                  height: 35,
                ),
                Icon(
                  Icons.person,
                  size: 45,
                  color: Colors.grey[800],
                ),
              ],
            ),
          ),

          // Message de bienvenue
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenue chez vous",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  "YAHYA CH",
                  style: GoogleFonts.bebasNeue(fontSize: 50),
                ),
              ],
            ),
          ),

          // Séparateur
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Divider(
              color: Colors.grey[800],
              thickness: 1,
            ),
          ),

          // Texte indiquant les appareils intelligents
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              "Appareils Intelligents",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Affichage de la température et de l'humidité
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              "Température = $temp°",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              "Humidité = $humidity",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
          ),

          // Grille d'affichage des appareils intelligents
          Expanded(
            child: GridView.builder(
              itemCount: mySmartDevices.length,
              padding: EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.2,
              ),
              itemBuilder: (context, index) {
                return SmartDeviceBox(
                  smartDeviceName: mySmartDevices[index][0],
                  iconPath: mySmartDevices[index][1],
                  powerOn: mySmartDevices[index][2],
                  onChanged: (value) {
                    powerSwitchChanged(value, index);
                    // Mise à jour de l'état du bouton pour le premier appareil
                    if (index == 0) {
                      sendToggleStateToFirebase(value);
                    }
                  },
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
