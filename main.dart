import 'package:diaguard1/features/patient/menu/edit_patientpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diaguard1/features/welcome/screens/usertype.dart';
import 'package:diaguard1/features/patient/patientScreens/questions.dart';
import 'package:diaguard1/features/patient/patientScreens/infopage_patient.dart';
import 'package:diaguard1/features/patient/patientScreens/patient_list.dart';
import 'package:diaguard1/features/patient/menu/patient_page.dart';
import 'package:diaguard1/features/patient/chartPatient/chart_patient.dart';
import 'package:diaguard1/features/patient/insulin_calc/insulin_calc.dart';
import 'package:diaguard1/core/service/auth.dart';
import 'package:diaguard1/core/service/glucose_service.dart';
import 'package:diaguard1/features/patient/chatbot/chatbot_patient.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:diaguard1/features/patient/patientScreens/glucose_alert_settings.dart'; 



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/language',
      fallbackLocale: Locale('en'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diaguard App',
      theme: ThemeData(primarySwatch: Colors.teal),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: AppUser(),
      routes: {
        '/insulin_calc': (context) => InsulinInfoPage(),
        '/infopage_patient': (context) => PatientInformation(
              userName: "",
              authService: AuthService(),
            ),
        '/chart_patient': (context) => ChartLabsPage(
              glucoseService: GlucoseService(authService: AuthService()),
            ),
        '/home': (context) => BarHome(
              userName: "",
              authService: AuthService(),
            ),
        '/chatbot_patient': (context) => ChatbotPatientPage(), 
      },
    );
  }
}