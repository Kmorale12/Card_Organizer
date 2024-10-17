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
    {'name': 'Ace of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Playing_card_heart_A.svg/800px-Playing_card_heart_A.svg.png', 'folderId': heartsId},
    {'name': 'King of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6ZrlP8ylZL8JRT-T4VDDqwLmLppx_I6IOeA&s', 'folderId': heartsId},
    {'name': 'Queen of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://i.etsystatic.com/5199369/r/il/f9a5d8/2811187962/il_fullxfull.2811187962_sb8r.jpg', 'folder_id': heartsId},
    {'name': 'Ace of Spades', 'suit': 'Spades', 'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/01_of_spades_A.svg/1200px-01_of_spades_A.svg.png', 'folder_id': spadesId},
    {'name': 'King of Spades', 'suit': 'Spades', 'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGZYVVfsGHpfwICusY5xeUcEp1rMoBAgh6HA&s', 'folder_id': spadesId},
    {'name': 'Queen of Spades', 'suit': 'Spades', 'imageUrl': 'https://media.istockphoto.com/id/1487488158/vector/ace-of-diamonds-playing-card-with-clipping-path-3d-illustration.jpg?s=612x612&w=0&k=20&c=Izkcoy9CkjWVws8BPFN0V3kAkSQKcmzaak6PsEzRDq8=', 'folder_id': spadesId},
    {'name': 'Ace of Diamonds', 'suit': 'Diamonds', 'imageUrl': 'https://www.keen.com/wp-content/uploads/sites/2/2022/08/Ace-of-Diamonds-Meaning-scaled.jpg', 'folder_id': diamondsId},
    {'name': 'King of Diamonds', 'suit': 'Diamonds', 'imageUrl': 'https://m.media-amazon.com/images/I/71EkglvyWjL._AC_UF1000,1000_QL80_.jpg', 'folder_id': diamondsId},
    {'name': 'Queen of Diamonds', 'suit': 'Diamonds', 'imageUrl': 'https://example.com/queen_diamonds.png', 'folder_id': diamondsId},
    {'name': 'Ace of Clubs', 'suit': 'Clubs', 'image_url': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Ace_of_clubs.png', 'folder_id': clubsId},
    {'name': 'King of Clubs', 'suit': 'Clubs', 'imageUrl': 'https://t4.ftcdn.net/jpg/03/63/34/15/360_F_363341511_Sjj7wKn8VLw4bFFDKvTInEurq9P06SAO.jpg', 'folder_id': clubsId},
    {'name': 'Queen of Clubs', 'suit': 'Clubs', 'imageUrl': 'https://as1.ftcdn.net/v2/jpg/05/44/97/40/1000_F_544974061_xqzOrYqQphAuL4ITHjtubB5mBMDPOsbA.jpg', 'folder_id': clubsId},
    {'name': 'Jack of Clubs', 'suit': 'Clubs', 'image_url': 'https://media.istockphoto.com/id/163680097/photo/playing-card-jack-of-clubs.jpg?s=612x612&w=0&k=20&c=ca9ofn7fCugcgHB2G9WU1cEH8TOw48OuwbgjOpZwzDQ=', 'folder_id': clubsId},
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
