import 'package:example_sliver_row_box/backdrop_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'back.dart';
import 'backdrop.dart';
import 'example.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SliverRowBox',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(const Color(0xFF80ba27)),
      ),
      home: const MyHomePage(title: 'SliverRowBox'),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 250, 241),
      body: SafeArea(
        child: Backdrop(
          appBar: BackDropAppbar(),
          back: Center(
            child: SizedBox(
              width: 900.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Back(),
              ),
            ),
          ),
          body: Material(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.0),
                  topRight: Radius.circular(36.0)),
            ),
            color: Color(0xFF80ba27),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 900.0,
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(36.0)),
                      child: CustomScrollView(
                        slivers: [AnimalsAtoZ()],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Add items',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
