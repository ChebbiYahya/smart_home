#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

// Définition des constantes
#define DHTPIN 21     // Pin sur laquelle le DHT11 est connecté (GPIO 21)
#define DHTTYPE DHT11 // Type de capteur DHT11
DHT dht(DHTPIN, DHTTYPE);

const int LEDPIN = 22;  // Le GPIO 22 est utilisé pour contrôler la LED

// Informations de connexion Firebase
#define WIFI_SSID "Downstairs 2.4 Ghz"//"HUAWEI-2.4G-Nwp6" //"HUAWEI-2.4G-GEj8" // SSID du réseau Wi-Fi
#define WIFI_PASSWORD "Hubio2021"//"d5aY3H4x" //"aU2nKfan"      // Mot de passe du réseau Wi-Fi
#define API_KEY "AIzaSyDRGZTmPsomUQLcKYI9bG3Yc1S2UGFLJ8s" // Clé API de Firebase
#define DATABASE_URL "https://smart-home-ce704-default-rtdb.firebaseio.com/" // URL de la base de données Firebase
#define USER_EMAIL "yahya@gmail.com"   // Adresse email de l'utilisateur pour Firebase
#define USER_PASSWORD "yahyayahya"     // Mot de passe de l'utilisateur pour Firebase

// Initialisation de Firebase
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);

  // Configuration du Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
  }

  // Configuration de Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;

  Firebase.begin(&config, &auth);

  // Initialisation du capteur DHT11
  dht.begin();

  // Configurer la broche de la LED
  pinMode(LEDPIN, OUTPUT);
}

void loop() {
  // Attendre 2 secondes entre chaque lecture
  delay(2000);
  
  // Lire les valeurs du capteur DHT11
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Vérifier la validité des lectures
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Erreur de lecture du DHT11 !");
    return;
  }

  // Afficher les valeurs lues
  Serial.print("Température: ");
  Serial.print(temperature);
  Serial.println(" °C");

  Serial.print("Humidité: ");
  Serial.print(humidity);
  Serial.println(" %");

  // Envoyer les valeurs à Firebase
  if (Firebase.setDouble(fbdo, F("/temperature"), temperature)) {
    Serial.printf("Envoyé température: %f\n", temperature);
  } else {
    Serial.println(fbdo.errorReason());
  }

  if (Firebase.setDouble(fbdo, F("/humidity"), humidity)) {
    Serial.printf("Envoyé humidité: %f\n", humidity);
  } else {
    Serial.println(fbdo.errorReason());
  }

  // Recevoir une valeur lorsqu'un bouton est pressé
  if (Firebase.getBool(fbdo, F("/bouton"))) {
    bool buttonValue = fbdo.to<bool>();
    Serial.printf("Valeur reçue du bouton: %s\n", buttonValue ? "true" : "false");
    
    // Allumer ou éteindre la LED selon la valeur du bouton
    if (buttonValue) {
      digitalWrite(LEDPIN, HIGH);
    } else {
      digitalWrite(LEDPIN, LOW);
    }
  } else {
    Serial.println(fbdo.errorReason());
  }
}
