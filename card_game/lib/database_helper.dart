import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
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

    await db.insert('folders', {'name': 'Hearts'});
    await db.insert('folders', {'name': 'Spades'});
    await db.insert('folders', {'name': 'Diamonds'});
    await db.insert('folders', {'name': 'Clubs'});

  
    
     // Fetch folder IDs to associate with cards
  List<Map<String, dynamic>> folders = await db.query('folders');
  int heartsId = folders.firstWhere((folder) => folder['name'] == 'Hearts')['id'];
  int spadesId = folders.firstWhere((folder) => folder['name'] == 'Spades')['id'];
  int diamondsId = folders.firstWhere((folder) => folder['name'] == 'Diamonds')['id'];
  int clubsId = folders.firstWhere((folder) => folder['name'] == 'Clubs')['id'];

 await db.insert('cards', {'name': 'Ace of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://example.com/ace_hearts.png', 'folderId': heartsId});
 await db.insert('cards', {'name': 'Ace of Hearts', 'suit': 'Spades', 'imageUrl': 'https://example.com/ace_hearts.png', 'folderId': spadesId});
 
 
  // Prepopulate 13 cards with different suits
  List<Map<String, dynamic>> prepopulatedCards = [
    {'name': 'Ace of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://example.com/ace_hearts.png', 'folderId': heartsId},
    {'name': 'King of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://example.com/king_hearts.png', 'folderId': heartsId},
    {'name': 'Queen of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://example.com/queen_hearts.png', 'folder_id': heartsId},
    {'name': 'Ace of Spades', 'suit': 'Spades', 'imageUrl': 'https://example.com/ace_spades.png', 'folder_id': spadesId},
    {'name': 'King of Spades', 'suit': 'Spades', 'image_url': 'https://example.com/king_spades.png', 'folder_id': spadesId},
    {'name': 'Queen of Spades', 'suit': 'Spades', 'imageUrl': 'https://example.com/queen_spades.png', 'folder_id': spadesId},
    {'name': 'Ace of Diamonds', 'suit': 'Diamonds', 'imageUrl': 'https://example.com/ace_diamonds.png', 'folder_id': diamondsId},
    {'name': 'King of Diamonds', 'suit': 'Diamonds', 'imageUrl': 'https://example.com/king_diamonds.png', 'folder_id': diamondsId},
    {'name': 'Queen of Diamonds', 'suit': 'Diamonds', 'imageUrl': 'https://example.com/queen_diamonds.png', 'folder_id': diamondsId},
    {'name': 'Ace of Clubs', 'suit': 'Clubs', 'image_url': 'https://example.com/ace_clubs.png', 'folder_id': clubsId},
    {'name': 'King of Clubs', 'suit': 'Clubs', 'imageUrl': 'https://example.com/king_clubs.png', 'folder_id': clubsId},
    {'name': 'Queen of Clubs', 'suit': 'Clubs', 'imageUrl': 'https://example.com/queen_clubs.png', 'folder_id': clubsId},
    {'name': 'Jack of Clubs', 'suit': 'Clubs', 'image_url': 'https://example.com/jack_clubs.png', 'folder_id': clubsId},
  ];

   for (var card in prepopulatedCards) {
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

   Future<List<Map<String, dynamic>>> getCardsByFolder(int folderId) async {
    final db = await database;
    return await db.query('cards', where: 'folderId = ?', whereArgs: [folderId]);
  }

 
}

class Folder {
  int? id;
  String folderName;
  String timestamp;

  Folder({this.id, required this.folderName, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': folderName,
      'timestamp': timestamp,
    };
  }
}

class CardModel {
  int? id;
  String name;
  String suit;
  String imageUrl;
  int folderId;

  CardModel({this.id, required this.name, required this.suit, required this.imageUrl, required this.folderId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'imageUrl': imageUrl,
      'folderId': folderId,
    };
  }
}
