import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRx',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'SmartRx'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  List<DynamicWidget> dynamicList = [];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class InformationUpdate extends StatefulWidget {
  InformationUpdate(this.color);

  final String color;

  @override
  _InformationUpdate createState() => _InformationUpdate(color);
}

class _InformationUpdate extends State<InformationUpdate> {
  _InformationUpdate(this.name);

  String name;

  int _value = 1;
  String colorName = "White";
  String placeholderTime1 = "Time between pills";
  String placeholderTime2 = "Pills per day";
  String placeholderSetPills1 = "Set Time for taking a pill";
  String placeholderPillsDay1 = "Pills per day";
  String placeholderPillsDay2 = "Estimated Bedtime";

  String text1 = "Time between pills";
  String text2 = "Pills per day";

  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController1.dispose();
    myController2.dispose();
    myController3.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Settings for " + name),
        ),
        body: Center(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: DropdownButton(
                    value: _value,
                    items: [
                      DropdownMenuItem(
                        child: Text("Time Intervals"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("Set Time"),
                        value: 2,
                      ),
                      DropdownMenuItem(child: Text("Set Pills"), value: 3),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                        if (_value == 1) {
                          text1 = placeholderTime1;
                          text2 = placeholderTime2;
                        } else if (_value == 2) {
                          text1 = placeholderSetPills1;
                          text2 = placeholderSetPills1;
                        } else {
                          text1 = placeholderPillsDay1;
                          text2 = placeholderPillsDay2;
                        }
                      });
                    }),
              ),
              Container(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: text1),
                  textAlign: TextAlign.center,
                  controller: myController1,
                ),
              ),
              Container(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: text2),
                  textAlign: TextAlign.center,
                  controller: myController2,
                ),
              ),
              Container(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Name of pill"),
                  textAlign: TextAlign.center,
                  controller: myController3,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _value.toString() + "*" + myController1.text + "*" + myController2.text + "*" + myController3.text);
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  print("OOP");
                },
                child: Text('Override'),
              ),
            ])));
  }
}

class DynamicWidget extends StatefulWidget {
  DynamicWidget(this.color, this.colorName);

  final Color color;
  final String colorName;

  _DynamicWidget createState() => _DynamicWidget(color, colorName, colorName);
}

class _DynamicWidget extends State<DynamicWidget> {
  _DynamicWidget(this.color, this.colorName, this.colorSave);

  String result;

  String colorSave;

  Color color;
  String colorName;
  int timeSave = 40;
  int timeLeft = 40;
  Timer _timer;
  String display = "Set";
  int totalPills = 1;

  void startCounter() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (timeLeft == 0 && totalPills-- <= 1) {
          display = "Done";
          setState(() {
            timer.cancel();
          });
        } else if (timeLeft == 0) {
          timeLeft = timeSave;
        } else {
          setState(() {
            timeLeft--;
            if (timeLeft % 60 >= 10) {
              display = (timeLeft / 60).floor().toString() + ":" +
                  (timeLeft % 60).toString();
            } else {
              display = (timeLeft / 60).floor().toString() + ":0" +
                  (timeLeft % 60).toString();
            }
          });
        }
      },
    );
  }

  void initState() {
    super.initState();
    startCounter();
  }

  _settings(BuildContext context) async {
    result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InformationUpdate(colorName)),
    );
    print(result);

    colorName = result.split("*")[3];
    totalPills = int.parse(result.split("*")[2]);
    timeSave = 60 * int.parse(result.split("*")[1].split(":")[0]) + int.parse(result.split("*")[1].split(":")[1]);

    this.setState(() {});

    var client = http.Client();
    try {
      print(colorSave);
      var url = 'http://172.20.10.11:3000/'+colorSave;
      print(url);
      client.post(url,
          body: json.encode({'alive': true, 'total-pills': totalPills, 'time-til': timeLeft, 'time-save': timeSave, 'name': colorName}),
          headers: {'Content-type': 'application/json'}).then((response) {
        print("Sent");
      });
    } finally {
      client.close();
    }// Forcing Widget Update
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//      margin: new EdgeInsets.all(8.0),
      child: ListBody(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                _settings(context);
              },
              child: Container(
                  margin: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  constraints: BoxConstraints.expand(
                    height: Theme.of(context).textTheme.headline4.fontSize * .2 + 156.2,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[800],
                  alignment: Alignment.center,
                  child: Column(
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                height: 36.0,
                                width: 36.0,
                                child: FlatButton(
                                  child: Icon(Icons.delete),
                                  onPressed: () {},
                                ),
                              ),
                              Text('$display',
                                  style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white)),
                              Container(
                                margin: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                                width: 36.0,
                                height: 36.0,
                              ),
                            ]),
                        Text(colorName + "    Pills Left: " + totalPills.toString() ,
                          style: TextStyle(color: Colors.white),
                        )
                      ])))
        ],
      ),
    );
  }

}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _messaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    _messaging.getToken().then((token) {
      print(token);
    });
  }

  int _counter = 0;
  bool newStatus = false;

  void toggleSwitch(switchStatus) {
    var client = http.Client();
    try {
      var url = 'http://172.20.10.11:3000/switchLed';
      client.post(url,
          body: json.encode({'absolute-time': true}),
          headers: {'Content-type': 'application/json'}).then((response) {
        print('status: ${newStatus.toString()}');
      });
    } finally {
      client.close();
    }
    setState(() {
      newStatus = !newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> colorNames = [
      "Red",
      "White",
      "Green",
      "Blue",
    ];
    List<Color> colors = [
      Colors.red[500],
      Colors.white,
      Colors.green[500],
      Colors.blue[500]
    ];
    List<Widget> children = new List.generate(
        _counter, (int i) => new DynamicWidget(colors[i], colorNames[i]));

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children
            // <Widget>[
            //   RaisedButton.icon(onPressed: null, icon: Icon(Icons.add), label: Text("Add")),
            //   Text(
            //     'Turn the led ${newStatus!=true?'on':'off'}',
            //     style: TextStyle(fontSize: 32),
            //   ),
            //   Transform.scale(
            //     scale: 3.0,
            //     child: new Switch(onChanged: toggleSwitch, value: newStatus),
            //   ),
            // ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            setState(() {
              if (_counter < 4) {
                _counter = _counter + 1;
              }
            });
          },
        ));
  }
}
