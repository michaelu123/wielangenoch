import 'package:flutter/material.dart';

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
  String _msg = "";

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(0),
      lastDate: DateTime(3000),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() => dateFuture = pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dateFuture != null) {
      _msg = datesToMsg(dateFuture!);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _msg,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: _presentDatePicker,
              child: const Text(
                'Wähle ein Datum',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String datesToMsg(DateTime dateFuture) {
  DateTime dateNow = DateTime.now();
  dateNow = DateTime.utc(dateNow.year, dateNow.month, dateNow.day);
  dateFuture = DateTime.utc(dateFuture.year, dateFuture.month, dateFuture.day);
  // print("dtm $dateNow $dateFuture");
  String msg = "Noch ";
  bool akkusativ = true;
  int cmp = dateNow.compareTo(dateFuture);
  if (cmp == 0) {
    msg = "Heute!";
    return msg;
  } else if (cmp > 0) {
    msg = "Vor ";
    akkusativ = false;
    (dateNow, dateFuture) = (dateFuture, dateNow);
  }

  DateTime date = dateNow;
  int days = dateFuture.difference(dateNow).inDays;
  // print("days $days");
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
    msg = "${msg + y.toString()} Jahr${plural(y, akkusativ)}";
    if (m > 0 && d > 0) {
      msg = "$msg, ";
    } else if (m > 0 || d > 0) {
      msg = "$msg und ";
    }
  }
  if (m > 0) {
    msg = "${msg + m.toString()} Monat${plural(m, akkusativ)}";
    if (d > 0) msg = "$msg und ";
  }
  if (d > 0 || y == 0 && m == 0) {
    msg = "$msg$d Tag${plural(d, akkusativ)}";
  }
  if (m > 0 || y > 0) {
    msg = "$msg,\n$days Tag${plural(days, akkusativ)} insgesamt";
  }
  return msg;
}

String plural(int cnt, bool akkusativ) {
  return cnt != 1 ? (akkusativ ? "e" : "en") : "";
}
