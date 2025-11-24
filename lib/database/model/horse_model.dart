String idColumn = "idColumn";
String nameColumn = "nameColumn";
String ageColumn = "ageColumn";
String coatColorColumn = "coatColorColumn";
String genderColumn = "genderColumn";
String totalRacesColumn = "totalRacesColumn";
String totalWinsColumn = "totalWinsColumn";
String lastVictoryDateColumn = "lastVictoryDateColumn";
String imageColumn = "imageColumn";
String horseTable = "horseTable";

class Horse {
  int? id;
  String name;
  int age;
  String coatColor;
  String gender;
  int totalRaces;
  int totalWins;
  int? lastVictoryDate;
  String? image;

  Horse({
    this.id,
    required this.name,
    required this.age,
    required this.coatColor,
    required this.gender,
    required this.totalRaces,
    required this.totalWins,
    this.lastVictoryDate,
    this.image,
  });

  Horse.fromMap(Map<String, dynamic> map)
    : id = map[idColumn],
      name = map[nameColumn],
      age = map[ageColumn],
      coatColor = map[coatColorColumn],
      gender = map[genderColumn],
      totalRaces = map[totalRacesColumn],
      totalWins = map[totalWinsColumn],
      lastVictoryDate = map[lastVictoryDateColumn],
      image = map[imageColumn];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      ageColumn: age,
      coatColorColumn: coatColor,
      genderColumn: gender,
      totalRacesColumn: totalRaces,
      totalWinsColumn: totalWins,
      lastVictoryDateColumn: lastVictoryDate,
      imageColumn: image,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Horse(id: $id, name: $name, age: $age, coatColor: $coatColor, gender: $gender, totalRaces: $totalRaces, totalWins: $totalWins, lastVictoryDate: $lastVictoryDate,  image: $image)";
  }
}
