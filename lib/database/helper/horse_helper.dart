import 'package:apk_catalogo/database/model/horse_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HorseHelper {
  static final HorseHelper _instance = HorseHelper.internal();
  factory HorseHelper() => _instance;
  HorseHelper.internal();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDB();
      return _db!;
    }
  }

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "horsesDB.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute(
          "CREATE TABLE $horseTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $ageColumn INTEGER, $coatColorColumn TEXT, $genderColumn TEXT, $totalRacesColumn INTEGER, $totalWinsColumn INTEGER, $lastVictoryDateColumn INTEGER, $imageColumn TEXT)",
        );
      },
    );
  }

  Future<Horse> saveHorse(Horse horse) async {
    Database dbHorse = await db;
    horse.id = await dbHorse.insert(horseTable, horse.toMap());
    return horse;
  }

  Future<Horse?> getHorse(int id) async {
    Database dbHorse = await db;
    List<Map<String, dynamic>> maps = await dbHorse.query(
      horseTable,
      columns: [
        idColumn,
        nameColumn,
        ageColumn,
        coatColorColumn,
        genderColumn,
        totalRacesColumn,
        totalWinsColumn,
        lastVictoryDateColumn,
        imageColumn,
      ],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Horse.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Horse>> getAllHorses() async {
    Database dbHorse = await db;
    List<Map<String, dynamic>> maps = await dbHorse.query(horseTable);
    List<Horse> listHorse = [];
    for (Map<String, dynamic> m in maps) {
      listHorse.add(Horse.fromMap(m));
    }
    return listHorse;
  }

  Future<int> deleteHorse(int id) async {
    Database dbHorse = await db;
    return await dbHorse.delete(
      horseTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateHorse(Horse horse) async {
    Database dbHorse = await db;
    return await dbHorse.update(
      horseTable,
      horse.toMap(),
      where: "$idColumn = ?",
      whereArgs: [horse.id],
    );
  }
}
