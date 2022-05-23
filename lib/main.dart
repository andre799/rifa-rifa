import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rifa_rifa/services/rifa_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/model/rifa_model.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC1DlYOhBV87Ko_n1PZP5s2yRx8_uDcLHw",
          authDomain: "rifa-rifa.firebaseapp.com",
          projectId: "rifa-rifa",
          storageBucket: "rifa-rifa.appspot.com",
          messagingSenderId: "470701417663",
          appId: "1:470701417663:web:69bafd88a6858ed300520a",
          measurementId: "G-J0LHTFCPBE"));

  runApp(MaterialApp(
    theme: ThemeData(primarySwatch: createMaterialColor(Colors.indigo[900]!)),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final service = RifaService();

  final selectedNumbers = <num>[];

  void selectNumber(num number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
        return;
      }
      selectedNumbers.add(number);
    });
  }

  void confirmClick() {
    if (selectedNumbers.isEmpty) return;

    final message = """
*SORTEIO KIT CHURRASCO: LARA E LORENA*\n
Olá André! Gostaria de reservar os seguintes números para concorrer ao prêmio *KIT CARNES churrasco - 2 fardos AMSTEL - 2 COCAS*\n
Números selecionados: ${selectedNumbers.join(' - ')}
    """;

    launchUrl(Uri.parse(
        'https://api.whatsapp.com/send?phone=5516991478377&text=$message'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Rifa Lara e Lorena'),
        centerTitle: false,
        actions: [
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Voltar'))
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          content: Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                ListTile(
                                  title: Text('- 1 Kg Pernil Temperado'),
                                ),
                                ListTile(
                                  title: Text('- 1 Kg Fraldinha na manteiga'),
                                ),
                                ListTile(
                                  title: Text('- 1 Kg Bife Costela Temperado'),
                                ),
                                ListTile(
                                  title: Text('- 1 Kg Linguiça Toscana'),
                                ),
                                ListTile(
                                  title: Text('- 1 Kg Filé de Coxa'),
                                ),
                                ListTile(
                                  title: Text('- 1 Pct Pão de Alho'),
                                ),
                                ListTile(
                                  title: Text(
                                      '- 2 Fardos (2x 12 unid.) Amstel 350ml'),
                                ),
                                ListTile(
                                  title: Text('- 2 Cocas 2 litros'),
                                )
                              ],
                            ),
                          ),
                        ));
              },
              child: const Text(
                'Ver Itens do Kit',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: selectedNumbers.isEmpty
              ? const SizedBox()
              : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    minimumSize: MaterialStateProperty.all(const Size(400, 60)),
                    elevation: MaterialStateProperty.all(5),
                    shadowColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                  ),
                  onPressed: confirmClick,
                  child: Text(
                    'CONFIRMAR',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Selecione os números para concorrer:\nKIT CARNES churrasco + 2 fardos AMSTEL + 2 COCAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Valor: 1 número R\$ 15,00 ou 4 números R\$ 50.00',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: FutureBuilder<num>(
                future: service.getCount(),
                builder: (_, snapshot) {
                  final count = snapshot.data;

                  return StreamBuilder<List<RifaModel>>(
                      stream: service.getRifas(),
                      builder: (context, snapshot) {
                        final rifas = snapshot.data;
                        final numbers = rifas == null
                            ? []
                            : rifas.map((e) => e.number).toList();

                        return AnimatedSwitcher(
                          duration: const Duration(),
                          child: count != null && rifas != null
                              ? SizedBox(
                                  width: double.infinity,
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return ListView(
                                      children: [
                                        Wrap(
                                          alignment: WrapAlignment.spaceEvenly,
                                          children: Iterable<int>.generate(
                                                  count.toInt())
                                              .map((e) => RifaCard(
                                                  isLarge:
                                                      constraints.maxWidth >
                                                          500,
                                                  isSelected: selectedNumbers
                                                      .contains(e + 1),
                                                  isDisponible:
                                                      !numbers.contains(e + 1),
                                                  onSelect: () =>
                                                      selectNumber(e + 1),
                                                  number: e + 1))
                                              .toList(),
                                        )
                                      ],
                                    );
                                  }),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        );
                      });
                }),
          )
        ],
      ),
    );
  }
}

class RifaCard extends StatelessWidget {
  final bool isSelected;
  final bool isDisponible;
  final VoidCallback onSelect;
  final num number;
  final bool isLarge;

  const RifaCard(
      {Key? key,
      required this.isSelected,
      required this.isDisponible,
      required this.isLarge,
      required this.onSelect,
      required this.number})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isDisponible ? onSelect : null,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isLarge ? 80 : 60,
          width: isLarge ? 120 : 90,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: !isDisponible
                  ? Colors.grey[350]
                  : isSelected
                      ? Colors.white
                      : Theme.of(context).primaryColor,
              border: Border.all(
                width: 3,
                color: !isDisponible
                    ? Colors.grey
                    : !isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
              )),
          child: Center(
            child: Text(
              number.toStringAsFixed(0),
              style: TextStyle(
                  color: !isDisponible
                      ? Colors.grey
                      : !isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
