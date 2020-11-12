import 'package:wikihero/models/appearance.dart';
import 'package:wikihero/models/biography.dart';
import 'package:wikihero/models/connections.dart';
import 'package:wikihero/models/image.dart';
import 'package:wikihero/models/powerstats.dart';
import 'package:wikihero/models/work.dart';

class Superhero {
  String id;
  String name;
  PowerStats powerstats;
  Biography biography;
  Appearance appearance;
  Work work;
  Connections connections;
  HeroImage image;
  String json;
  Superhero(
      {this.id,
      this.name,
      this.powerstats,
      this.biography,
      this.appearance,
      this.work,
      this.connections,
      this.image,
      this.json});
}
