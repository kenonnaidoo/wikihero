import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:wikihero/models/appearance.dart';
import 'package:wikihero/models/biography.dart';
import 'package:wikihero/models/connections.dart';
import 'package:wikihero/models/image.dart';
import 'package:wikihero/models/powerstats.dart';
import 'package:wikihero/models/superhero.dart';
import 'package:wikihero/models/work.dart';

class Versus extends StatefulWidget {
  Versus({Key key}) : super(key: key);

  static Superhero superhero1;
  static Superhero superhero2;

  static Future<List<Superhero>> search(String query) async {
    List<Superhero> list = [];

    String url =
        'https://www.superheroapi.com/api.php/868006950673602/search/' + query;
    Map<String, String> headers = {"Content-type": "application/json"};

    // make POST request
    Response response = await get(url, headers: headers);

    //this API passes back the id of the new item added to the body
    String body = response.body;
    print(body);
    Map<dynamic, dynamic> _json = await jsonDecode(body);
    List<dynamic> _results = _json["results"];

    if (_results == null) {
      return null;
    }

    for (var i = 0; i < _results.length; i++) {
      Map<String, dynamic> result = _results[i];

      String id = result["id"];
      String name = result["name"];

      PowerStats powerStats = PowerStats(
          intelligence: result["powerstats"]["intelligence"],
          strength: result["powerstats"]["strength"],
          speed: result["powerstats"]["speed"],
          durability: result["powerstats"]["durability"],
          power: result["powerstats"]["power"],
          combat: result["powerstats"]["combat"]);

      Biography biography = Biography(
          fullName: result["biography"]["full-name"],
          alterEgos: result["biography"]["alter-egos"],
          aliases: result["biography"]["aliases"],
          placeOfBirth: result["biography"]["place-of-birth"],
          firstAppearance: result["biography"]["first-appearance"],
          publisher: result["biography"]["publisher"],
          alignment: result["biography"]["alignment"]);

      Appearance appearance = Appearance(
        gender: result["appearance"]["gender"],
        race: result["appearance"]["race"],
        height: [
          result["appearance"]["height"][0],
          result["appearance"]["height"][1],
        ],
        weight: [
          result["appearance"]["weight"][0],
          result["appearance"]["weight"][1],
        ],
        eyeColor: result["appearance"]["eye-color"],
        hairColor: result["appearance"]["hair-color"],
      );

      Work work = Work(
        occupation: result["work"]["occupation"],
        base: result["work"]["base"],
      );

      Connections connections = Connections(
          groupAffiliation: result["connections"]["group-affiliation"],
          relatives: result["connections"]["relatives"]);

      HeroImage image = HeroImage(url: result["image"]["url"]);

      String json = jsonEncode(result);

      list.add(Superhero(
          id: id,
          name: name,
          powerstats: powerStats,
          biography: biography,
          appearance: appearance,
          work: work,
          connections: connections,
          image: image,
          json: json));
    }

    return list;
  }

  @override
  _VersusState createState() => _VersusState();
}

class _VersusState extends State<Versus> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool rand = false;
  bool battling = false;

  void callback() {
    setState(() {
      rand = true;
    });
  }

  String getProgressValues(String superhero1, String superhero2) {
    var v1 = int.parse(superhero1);
    var v2 = int.parse(superhero2);
    var total = v1 + v2;
    var solution = (v1 / total) * 100;
    return solution.toString();
  }

  String getOverallWinner(Superhero superhero1, Superhero superhero2) {
    int superhero1Stats = int.parse(superhero1.powerstats.intelligence) +
        int.parse(superhero1.powerstats.strength) +
        int.parse(superhero1.powerstats.speed) +
        int.parse(superhero1.powerstats.durability) +
        int.parse(superhero1.powerstats.power) +
        int.parse(superhero1.powerstats.combat);

    int superhero2Stats = int.parse(superhero2.powerstats.intelligence) +
        int.parse(superhero2.powerstats.strength) +
        int.parse(superhero2.powerstats.speed) +
        int.parse(superhero2.powerstats.durability) +
        int.parse(superhero2.powerstats.power) +
        int.parse(superhero2.powerstats.combat);

    if (superhero1Stats > superhero2Stats) {
      return superhero1.biography.fullName;
    } else {
      if (superhero1Stats == superhero2Stats) {
        return "A Tie";
      } else {
        return superhero2.biography.fullName;
      }
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        title: Text("Battle"),
      ),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildVersusHeader(),
              SizedBox(
                height: 30,
              ),
              battling ? _buildBattleField() : _buildNoBattleField()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoBattleField() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (Versus.superhero1 != null && Versus.superhero2 != null) {
              setState(() {
                battling = true;
              });
            } else {
              showInSnackBar("Choose opponents first");
            }
          },
          child: Container(
            width: 200,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30)),
            child: Center(
                child: Text(
              "START BATTLE",
              style: TextStyle(color: Colors.white, fontSize: 15),
            )),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Center(
            child: Text(
          "Battle winner is based on a superheroe's stats \n such as intelligence, strength, speed, durability, \n power and combat values.",
          style: TextStyle(color: Colors.grey, fontSize: 15),
          textAlign: TextAlign.center,
        ))
      ],
    );
  }

  Widget _buildBattleField() {
    Superhero superhero1 = Versus.superhero1;
    Superhero superhero2 = Versus.superhero2;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          SizedBox(height: 15),
          Text("Overall Winner Is"),
          Text(
            getOverallWinner(superhero1, superhero2),
            style: TextStyle(fontSize: 30, fontFamily: "StreetFighter"),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Versus.superhero1.biography.fullName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.blue)),
                Text(Versus.superhero2.biography.fullName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.red[200])),
              ],
            ),
          ),
          buildStatProgress(
              "Intelligence",
              getProgressValues(superhero1.powerstats.intelligence,
                  superhero2.powerstats.intelligence)),
          buildStatProgress(
              "Strength",
              getProgressValues(superhero1.powerstats.strength,
                  superhero2.powerstats.strength)),
          buildStatProgress(
              "Durability",
              getProgressValues(superhero1.powerstats.durability,
                  superhero2.powerstats.durability)),
          buildStatProgress(
              "Power",
              getProgressValues(
                  superhero1.powerstats.power, superhero2.powerstats.power)),
          buildStatProgress(
              "Combat",
              getProgressValues(
                  superhero1.powerstats.combat, superhero2.powerstats.combat)),
        ],
      ),
    );
  }

  Widget buildStatProgress(String title, String value) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            SizedBox(
              height: 10,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        LinearProgressIndicator(
          minHeight: 20,
          backgroundColor: Colors.red[200],
          value: int.parse(value.split(".")[0]).floor() / 100,
        ),
        SizedBox(
          height: 10,
        ),
        Divider(),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildVersusHeader() {
    return Container(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showSearch(
                  context: context,
                  delegate: Search(superhero: "1", callback: callback));
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.black,
                    width: 3.0,
                  ),
                ),
                color: Colors.red,
                image: DecorationImage(
                  image: Versus.superhero1 == null
                      ? AssetImage("assets/placeholder.jpg")
                      : NetworkImage(Versus.superhero1.image.url),
                  fit: BoxFit.cover,
                ),
              ),
              height: 300,
              width: MediaQuery.of(context).size.width / 2,
              child: Center(
                  child: Icon(
                Icons.add,
                size: 50,
              )),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () {
                showSearch(
                    context: context,
                    delegate: Search(superhero: "2", callback: callback));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  image: DecorationImage(
                    image: Versus.superhero2 == null
                        ? AssetImage("assets/placeholder.jpg")
                        : NetworkImage(Versus.superhero2.image.url),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 300,
                width: MediaQuery.of(context).size.width / 2,
                child: Center(
                    child: Icon(
                  Icons.add,
                  size: 50,
                )),
              ),
            ),
          ),
          Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Icon(
                    Icons.offline_bolt,
                    size: 50,
                  ))),
        ],
      ),
    );
  }
}

class Search extends SearchDelegate<String> {
  String superhero;
  Function callback;

  Search({this.superhero, this.callback});

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          close(context, "superhero");
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults

    return FutureBuilder(
      future: Versus.search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return ListTile(
                    onTap: () {
                      if (superhero == "1") {
                        setState(() {
                          Versus.superhero1 = snapshot.data[index];
                        });
                      } else {
                        setState(() {
                          Versus.superhero2 = snapshot.data[index];
                        });
                      }
                      callback();
                      close(context, "superhero");
                    },
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(snapshot.data[index].image.url),
                    ),
                    title: Text(snapshot.data[index].biography.fullName != ""
                        ? snapshot.data[index].biography.fullName
                        : "Unknown"),
                    subtitle: Text(snapshot.data[index].biography.publisher),
                  );
                });
              },
            );
          } else {
            return Container(
              width: double.infinity,
              height: 180,
              child: Center(
                child: Text("No results for '$query'"),
              ),
            );
          }
        } else {
          return Container(
            width: double.infinity,
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Container();
  }
}
