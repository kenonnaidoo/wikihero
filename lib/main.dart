import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wikihero/details.dart';
import 'package:wikihero/local/configs.dart';

import 'package:wikihero/models/appearance.dart';
import 'package:wikihero/models/biography.dart';
import 'package:wikihero/models/connections.dart';
import 'package:wikihero/models/image.dart';
import 'package:wikihero/models/powerstats.dart';
import 'package:wikihero/models/superhero.dart';
import 'package:wikihero/models/work.dart';

import 'package:shimmer/shimmer.dart';
import 'package:wikihero/versus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController keywordController = new TextEditingController();
  List<Superhero> superHeros = [];
  List<Superhero> recentSuperHeros = [];
  List<String> exploreItems = ["i", "c", "d", "f", "r"];

  bool exploreloading = true;
  bool searching = false;
  bool searchloading = false;
  bool notConnected = false;

  Future<bool> connected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<bool> configDevicePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("recents")) {
      List<Superhero> recentSuperheroes = [];
      Configs.saveSetting("recents", jsonEncode(recentSuperheroes));
      return false;
    }
    return false;
  }

  search(String query, List list, bool search) async {
    print("donfskdf");
    if (!search) {
      setState(() {
        list.clear();
        exploreloading = true;
      });
    } else {
      setState(() {
        list.clear();
        searchloading = true;
      });
    }

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
      setState(() {
        searchloading = false;
      });
    } else {
      var limit;
      if (_results.length > 10) {
        limit = 10;
      } else {
        limit = _results.length;
      }
      for (var i = 0; i < limit; i++) {
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

        setState(() {
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
        });
      }

      if (!search) {
        setState(() {
          exploreloading = false;
        });
      } else {
        setState(() {
          searchloading = false;
        });
      }
    }

    print(_json);
  }

  getRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> recentSH = jsonDecode(prefs.getString("recents"));

    if (recentSH.length > 0) {
      for (var i = 0; i < recentSH.length; i++) {
        Map<String, dynamic> result = jsonDecode(recentSH[i]);

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

        setState(() {
          recentSuperHeros.add(Superhero(
              id: id,
              name: name,
              powerstats: powerStats,
              biography: biography,
              appearance: appearance,
              work: work,
              connections: connections,
              image: image,
              json: json));
        });
      }
    } else {
      setState(() {
        recentSuperHeros = [];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configDevicePrefs().then((value) {
      getRecents();
      connected().then((internet) {
        if (internet) {
          Random random = new Random();
          search(exploreItems[random.nextInt(exploreItems.length)], superHeros,
              false);
        } else {
          setState(() {
            notConnected = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeading(),
              !notConnected
                  ? !searching ? homeScreen() : searchScreen()
                  : _buildNotConnectedScreen()
            ],
          ),
        ),
      ),
    );
  }

  Widget homeScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExploreHeader(),
        exploreloading ? loadingExplore() : _buildExploreList(),
        _buildHistoryHeader(),
        _buildHistoryList(),
      ],
    );
  }

  Widget _buildNotConnectedScreen() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.signal_wifi_off,
              size: 50,
              color: Colors.grey[400],
            ),
            SizedBox(
              height: 10,
            ),
            Text("No Internet Connection"),
          ],
        ),
      ),
    );
  }

  Widget searchScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(25.0),
            onTap: () {
              connected().then((internet) {
                if (internet) {
                  search("i", superHeros, false);
                  setState(() {
                    searching = false;
                  });
                } else {
                  setState(() {
                    notConnected = true;
                  });
                }
              });
            },
            child: Container(
              width: 120,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Back home")
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        searchloading ? searchScreenLoading() : _buildSearchResults(),
      ],
    );
  }

  Widget searchScreenLoading() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        children: [
          shimmerCommonItem(),
          shimmerCommonItem(),
          shimmerCommonItem()
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Find Your", style: TextStyle(fontSize: 25)),
            Text("Superhero",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          ],
        ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Versus()));
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(30.0)),
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.offline_bolt,
              size: 40,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHeading() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeaderText(),
          SizedBox(
            height: 30,
          ),
          Container(
              height: 55,
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: keywordController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(18.0),
                        hintText: 'Search hero...',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white70,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (keywordController.text != "") {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        setState(() {
                          searching = true;
                        });
                        search(keywordController.text, superHeros, true);
                      }
                    },
                    child: Container(
                        height: 55.0,
                        width: 55.0,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Icon(Icons.search,
                            size: 30.0, color: Colors.white)),
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildExploreHeader() {
    return Container(
      padding: EdgeInsets.only(bottom: 20, left: 20),
      child: Text("Explore Superheroes"),
    );
  }

  Widget _buildHistoryHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text("Recently Viewed"),
    );
  }

  Widget _buildExploreList() {
    return Container(
      height: 180,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return buildCard(superHeros[index], index);
        },
        scrollDirection: Axis.horizontal,
        itemCount: 5,
      ),
    );
  }

  Widget loadingExplore() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      height: 180,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return shimmerExploreItem(index);
        },
        scrollDirection: Axis.horizontal,
        itemCount: 5,
      ),
    );
  }

  Widget shimmerExploreItem(int index) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200],
      highlightColor: Colors.grey[400],
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey),
          height: 180,
          width: 210,
        ),
      ),
    );
  }

  Widget shimmerCommonItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200],
      highlightColor: Colors.grey[400],
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey),
          height: 180,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: recentSuperHeros.length == 0
          ? _noHistory()
          : Column(
              children: [
                ...recentSuperHeros.reversed.map((item) {
                  return buildCardHistory(item);
                }).toList(),
              ],
            ),
    );
  }

  Widget _noResults() {
    return Container(
      width: double.infinity,
      height: 200,
      child: Center(
        child: Text("No results found"),
      ),
    );
  }

  Widget _noHistory() {
    return Container(
      width: double.infinity,
      height: 100,
      child: Center(
        child: Text("No History Yet"),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: superHeros.length == 0
          ? _noResults()
          : Column(
              children: [
                ...superHeros.map((item) {
                  return buildCardHistory(item);
                }).toList(),
              ],
            ),
    );
  }

  Widget buildCard(Superhero superhero, int index) {
    return Hero(
      tag: superhero.id,
      child: Container(
        padding: index == 0
            ? EdgeInsets.only(left: 10)
            : index == 4 ? EdgeInsets.only(right: 10) : EdgeInsets.all(0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Details(
                          superhero: superhero,
                        )));
                setState(() {
                  recentSuperHeros.add(superhero);
                  if (recentSuperHeros.length > 5) {
                    recentSuperHeros.removeAt(0);
                  }
                });
              },
              child: Container(
                height: 180,
                width: 210,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    children: <Widget>[
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ).createShader(Rect.fromLTRB(
                              0, -140, rect.width, rect.height - 10));
                        },
                        blendMode: BlendMode.darken,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(superhero.image.url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          right: 20,
                          bottom: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(superhero.biography.fullName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "ProductSans"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                              SizedBox(
                                height: 10,
                              ),
                              Text(superhero.biography.publisher,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: "ProductSans"),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2)
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 0,
            )
          ],
        ),
      ),
    );
  }

  Widget buildCardHistory(Superhero superhero) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Details(
                      superhero: superhero,
                    )));
            setState(() {
              recentSuperHeros.add(superhero);
              if (recentSuperHeros.length > 5) {
                recentSuperHeros.removeAt(0);
              }
            });
          },
          child: Container(
            height: 180,
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                children: <Widget>[
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ).createShader(
                          Rect.fromLTRB(0, -140, rect.width, rect.height - 10));
                    },
                    blendMode: BlendMode.darken,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(superhero.image.url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      right: 20,
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(superhero.biography.fullName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: "ProductSans"),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2),
                          SizedBox(
                            height: 10,
                          ),
                          Text(superhero.biography.publisher,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "ProductSans"),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2)
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
