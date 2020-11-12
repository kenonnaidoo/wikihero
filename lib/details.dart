import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikihero/main.dart';

import 'package:wikihero/models/superhero.dart';

import 'package:wikihero/local/configs.dart';

class Details extends StatefulWidget {
  Superhero superhero;

  Details({this.superhero});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String bulletView(List<dynamic> list) {
    var itemCount = 0;
    StringBuffer sb = new StringBuffer();
    for (String line in list) {
      if (itemCount != list.length - 1) {
        sb.write(" • " + line + "\n");
      } else {
        sb.write(" • " + line);
      }
      itemCount++;
    }
    return sb.toString();
  }

  void addToRecent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> recentSH = jsonDecode(prefs.getString("recents"));
    if (recentSH.length >= 5) {
      recentSH.removeRange(0, recentSH.length - 4);
    }
    recentSH.add(widget.superhero.json);

    await Configs.saveSetting("recents", jsonEncode(recentSH));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addToRecent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 5,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(widget.superhero.biography.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: Hero(
                      tag: widget.superhero.id,
                      child: Image.network(
                        widget.superhero.image.url,
                        fit: BoxFit.cover,
                      ),
                    )),
              ),
              new SliverPadding(
                padding: new EdgeInsets.all(0.0),
                sliver: new SliverList(
                  delegate: new SliverChildListDelegate([
                    TabBar(
                      isScrollable: true,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        new Tab(text: "Biography"),
                        new Tab(text: "Powerstats"),
                        new Tab(text: "Appearance"),
                        new Tab(text: "Work"),
                        new Tab(text: "Connections"),
                      ],
                    ),
                  ]),
                ),
              ),
            ];
          },
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildBiography(),
              _buildPowerStats(),
              _buildAppearence(),
              _buildWork(),
              _buildConnections()
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTab(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(
          height: 10,
        ),
        Text(
          subtitle,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
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

  Widget infoTab2(String title, String subtitle) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            SizedBox(
              height: 10,
            ),
            Text(
              subtitle,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        LinearProgressIndicator(
          minHeight: 20,
          backgroundColor: Colors.red[200],
          value: int.parse(subtitle) / 100,
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

  Widget _buildBiography() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            infoTab("Full name: ", widget.superhero.biography.fullName),
            infoTab("Alter Ego's: ", widget.superhero.biography.alterEgos),
            infoTab(
                "Aliases: ", bulletView(widget.superhero.biography.aliases)),
            infoTab(
                "Place of birth: ", widget.superhero.biography.placeOfBirth),
            infoTab("First appearance: ",
                widget.superhero.biography.firstAppearance),
            infoTab("Publisher: ", widget.superhero.biography.publisher),
            infoTab("Alignment: ", widget.superhero.biography.alignment),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerStats() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            infoTab2(
                "Intelligence: ", widget.superhero.powerstats.intelligence),
            infoTab2("Strength: ", widget.superhero.powerstats.strength),
            infoTab2("Speed: ", widget.superhero.powerstats.speed),
            infoTab2("Durability: ", widget.superhero.powerstats.durability),
            infoTab2("Power: ", widget.superhero.powerstats.power),
            infoTab2("Combat: ", widget.superhero.powerstats.combat),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearence() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            infoTab("Gender: ", widget.superhero.appearance.gender),
            infoTab("Race: ", widget.superhero.appearance.race),
            infoTab(
                "Height: ",
                widget.superhero.appearance.height[0] +
                    " (${widget.superhero.appearance.height[1]})"),
            infoTab(
                "Weight: ",
                widget.superhero.appearance.weight[0] +
                    " (${widget.superhero.appearance.weight[1]})"),
            infoTab("Eye color: ",
                widget.superhero.appearance.eyeColor ?? "Unknown"),
            infoTab("Hair color: ",
                widget.superhero.appearance.hairColor ?? "Unknown"),
          ],
        ),
      ),
    );
  }

  Widget _buildWork() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            infoTab("Occupation: ", widget.superhero.work.occupation),
            infoTab("Base: ", widget.superhero.work.base),
          ],
        ),
      ),
    );
  }

  Widget _buildConnections() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            infoTab("Group Affiliation: ",
                widget.superhero.connections.groupAffiliation),
            infoTab("Relatives: ", widget.superhero.connections.relatives),
          ],
        ),
      ),
    );
  }
}
