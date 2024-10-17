import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY,
        name TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY,
        name TEXT,
        suit TEXT,
        imageUrl TEXT,
        folderId INTEGER,
        FOREIGN KEY (folderId) REFERENCES folders (id)
      )
    ''');

    // Prepopulate cards table
    List<Map<String, dynamic>> cards = [];
    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (String suit in suits) {
      for (int i = 1; i <= 13; i++) {
        cards.add({
          'name': '$i of $suit',
          'suit': suit,
          'imageUrl': 'https://example.com/$i_of_$suit.png',
          'folderId': null,
        });
      }
    }

    // Update the imageUrl for specific cards
    cards[0]['imageUrl'] = 'https://www.totalnonsense.com/b-w_ace.png'; // Ace of Hearts
    cards[1]['imageUrl'] = 'https://www.totalnonsense.com/b-w_2.png'; // 2 of Hearts
    cards[2]['imageUrl'] = 'https://www.totalnonsense.com/b-w_3.png'; // 3 of Hearts
    cards[3]['imageUrl'] = 'https://www.totalnonsense.com/b-w_4.png'; // 4 of Hearts
    cards[4]['imageUrl'] = 'https://www.totalnonsense.com/b-w_5.png'; // 5 of Hearts
    cards[5]['imageUrl'] = 'https://www.totalnonsense.com/b-w_6.png'; // 6 of Hearts
    cards[6]['imageUrl'] = 'https://www.totalnonsense.com/b-w_7.png'; // 7 of Hearts
    cards[7]['imageUrl'] = 'https://www.totalnonsense.com/b-w_8.png'; // 8 of Hearts
    cards[8]['imageUrl'] = 'https://www.totalnonsense.com/b-w_9.png'; // 9 of Hearts
    cards[9]['imageUrl'] = 'https://www.totalnonsense.com/b-w_10.png'; // 10 of Hearts
    cards[10]['imageUrl'] = 'https://www.totalnonsense.com/grayscale_jack.png'; // Jack of Hearts
    cards[11]['imageUrl'] = 'https://www.totalnonsense.com/b-w_queen.png'; // Queen of Hearts
    cards[12]['imageUrl'] = 'https://www.totalnonsense.com/b-w_king.png'; // King of Hearts

    for (var card in cards) {
      await db.insert('cards', card);
    }
  }

  // CRUD operations for folders and cards
  Future<List<Map<String, dynamic>>> getFolders() async {
    Database db = await database;
    return await db.query('folders');
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    Database db = await database;
    return await db.query('cards', where: 'folderId = ?', whereArgs: [folderId]);
  }

  Future<void> insertFolder(Map<String, dynamic> folder) async {
    Database db = await database;
    await db.insert('folders', folder);
  }

  Future<void> insertCard(Map<String, dynamic> card) async {
    Database db = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE folderId = ?', [card['folderId']]))!;
    if (count >= 6) {
      throw Exception('This folder can only hold 6 cards.');
    }
    await db.insert('cards', card);
  }

  Future<void> updateFolder(Map<String, dynamic> folder) async {
    Database db = await database;
    await db.update('folders', folder, where: 'id = ?', whereArgs: [folder['id']]);
  }

  Future<void> updateCard(Map<String, dynamic> card) async {
    Database db = await database;
    await db.update('cards', card, where: 'id = ?', whereArgs: [card['id']]);
  }

  Future<void> deleteFolder(int id) async {
    Database db = await database;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
    await db.delete('cards', where: 'folderId = ?', whereArgs: [id]);
  }

  Future<void> deleteCard(int id) async {
    Database db = await database;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Card>> fetchCards() async {
    final db = await _instance.database;
    final List<Map<String, dynamic>> cardMaps = await db.query('cards');
    return List.generate(cardMaps.length, (i) {
      return Card.fromMap(cardMaps[i]);
    });
  }
}

class Card {
  final int id;
  final String name;
  final String imageUrl;

  Card({required this.id, required this.name, required this.imageUrl});

  // Map card data from SQLite DB to Card object
  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
    );
  }
}