import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tapastop/screens/homeScreen.dart';
import 'package:tapastop/screens/loginScreen.dart';
import 'package:tapastop/utils/globals.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final Future<FirebaseApp> _init = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return FutureBuilder(
      future: _init,

      builder: (context, snapshot) {
        if (snapshot.hasError) throw Exception("Something went wrong");

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: LogSignInVM()),
            ],
            child: MaterialApp(
              title: 'tapasTop',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              themeMode: ThemeMode.light,
              supportedLocales: const [
                //Locale('en', ''), // English, no country code
                Locale('es', ''), // Spanish, no country code
              ],
              home: FutureBuilder(
                builder: (context, _ /*AsyncSnapshot<bool> snapshot*/) {
                  if (FirebaseAuth.instance.currentUser != null) {
                    return HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                },
              ),
            ),
          );
        }

        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: [Color(0xFFC677BF)],
            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
