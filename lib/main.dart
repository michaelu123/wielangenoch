import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WieLangeNoch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Wie lange noch?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? dateFuture;
  String msg = "";
  String selectedDate = "";
  bool usingForm = false;
  String eventName = "";
  late SharedPreferences prefs;

  Map<String, String> dates = {};

  Future<void> initData() async {
    prefs = await SharedPreferences.getInstance();
    for (String key in dates.keys) {
      await prefs.setString(key, dates[key]!);
    }
    for (String key in prefs.getKeys()) {
      String val = prefs.getString(key)!;
      print("key $key value $val");
      dates[key] = val;
    }
  }

  Future<void> presentDatePicker() async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(0),
      lastDate: DateTime(3000),
    ).then((pickedDate) async {
      if (pickedDate == null) return;
      eventName = eventName.trim();
      if (eventName == "") return;
      String date = pickedDate.toIso8601String().substring(0, 10);
      await prefs.setString(eventName, date);
      setState(() {
        dates[eventName] = date;
        selectedDate = eventName;
        dateFuture = pickedDate;
        usingForm = false;
      });
    });
  }

  void selectDate(String v) {
    setState(() {
      selectedDate = v;
      dateFuture = DateTime.tryParse(dates[v]!);
    });
  }

  Future<void> removeDate() async {
    await prefs.remove(selectedDate);
    setState(() {
      dates.remove(selectedDate);
      selectedDate = "";
      dateFuture = null;
      msg = "";
    });
  }

  void showForm() {
    setState(() {
      usingForm = true;
      eventName = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    msg = datesToMsg(dateFuture);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Neues Ereignis"),
            onPressed: showForm,
          ),
          const SizedBox(width: 30),
        ],
      ),
      body: FutureBuilder(
        future: initData(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container();
          }
          return Center(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    PopupMenuButton(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.amber,
                        ),
                        alignment: Alignment.center,
                        height: 50,
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            dates.isEmpty
                                ? "Erst Ereignisse anlegen"
                                : "Ereignis wählen",
                            style: const TextStyle(
                              // backgroundColor: Colors.red,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      itemBuilder: (_) => [
                        ...dates.keys.map((k) {
                          return PopupMenuItem(
                            value: k,
                            child: Text(k),
                          );
                        })
                      ],
                      onSelected: (v) {
                        selectDate(v);
                      },
                    ),
                    if (selectedDate != "")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$selectedDate: ${dates[selectedDate]}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: removeDate,
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    if (msg != "")
                      Card(
                        color: const Color.fromARGB(148, 231, 227, 226),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            msg,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (usingForm)
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: const EdgeInsets.all(50),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (v) {
                            eventName = v;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name des Ereignisses'),
                        ),
                        TextButton(
                          onPressed: presentDatePicker,
                          child: const Text(
                            'Wähle ein Datum',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String datesToMsg(DateTime? dateFuture) {
  if (dateFuture == null) return "";
  dateFuture = DateTime.utc(dateFuture.year, dateFuture.month, dateFuture.day);
  DateTime dateNow = DateTime.now();
  dateNow = DateTime.utc(dateNow.year, dateNow.month, dateNow.day);
  // print("dtm $dateNow $dateFuture");

  String msg = "Noch ";
  bool akkusativ = true;
  int cmp = dateNow.compareTo(dateFuture);
  if (cmp == 0) {
    return "Heute!";
  }
  if (cmp > 0) {
    msg = "Vor ";
    akkusativ = false;
    (dateNow, dateFuture) = (dateFuture, dateNow);
  }

  int days = dateFuture.difference(dateNow).inDays;
  // print("days $days");

  DateTime date = dateNow;
  int y = 0;
  for (;;) {
    date = DateTime.utc(dateNow.year + y + 1, dateNow.month, dateNow.day);
    // print("date1 $date");
    if (date.compareTo(dateFuture) <= 0) {
      y++;
    } else {
      break;
    }
  }
  int m = 0;
  for (;;) {
    date = DateTime.utc(dateNow.year + y, dateNow.month + m + 1, dateNow.day);
    // print("date2 $date");
    if (date.compareTo(dateFuture) <= 0) {
      m++;
    } else {
      break;
    }
  }
  int d = 0;
  for (;;) {
    date =
        DateTime.utc(dateNow.year + y, dateNow.month + m, dateNow.day + d + 1);
    // print("date3 $date");
    if (date.compareTo(dateFuture) <= 0) {
      d++;
    } else {
      break;
    }
  }
  // print("year $y month $m days $d");

  if (y > 0) {
    msg = "$msg$y Jahr${plural(y, akkusativ)}";
    if (m > 0 && d > 0) {
      msg = "$msg, ";
    } else if (m > 0 || d > 0) {
      msg = "$msg und ";
    }
  }
  if (m > 0) {
    msg = "$msg$m Monat${plural(m, akkusativ)}";
    if (d > 0) msg = "$msg und ";
  }
  if (d > 0 || y == 0 && m == 0) {
    msg = "$msg$d Tag${plural(d, akkusativ)}";
  }
  if (m > 0 || y > 0) {
    msg = "$msg,\ninsgesamt $days Tag${plural(days, akkusativ)}";
  }
  return msg;
}

String plural(int cnt, bool akkusativ) {
  return cnt != 1 ? (akkusativ ? "e" : "en") : "";
}
