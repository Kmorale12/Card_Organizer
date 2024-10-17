import 'database_helper.dart';
import 'card_list.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
 final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _folders = [
    {'id': 1, 'name': 'Hearts'},
    {'id': 2, 'name': 'Spades'},
    {'id': 3, 'name': 'Diamonds'},
    {'id': 4, 'name': 'Clubs'},
  ];

  
   
  
  Map<int, String> _folderImages = {};
  Map<int, int> _folderCardCounts = {};

@override
  void initState() {
    super.initState();
    _loadFolderData();
  }

  _loadFolderData() async {
    for (var folder in _folders) {
      final folderId = folder['id'];
      final cards = await dbHelper.getCardsByFolder(folderId);
      if (cards.isNotEmpty) {
        setState(() {
          _folderImages[folderId] = cards[0]['imageUrl']; // First card image
          _folderCardCounts[folderId] = cards.length; // Card count
        });
      } else {
        setState(() {
          _folderImages[folderId] = 'https://upload.wikimedia.org/wikipedia/commons/5/57/Playing_card_heart_A.svg'; // Placeholder image
          _folderCardCounts[folderId] = 0; // No cards
        });
      }
    }
  }

  
  
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
     
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       
        title: Text(widget.title),
      ),
      body:GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Display two folders per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          final folderId = folder['id'];
          return GestureDetector(
            onTap: () {
              // Navigate to the card list for the selected folder
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardListScreen(folderId: folderId),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      _folderImages[folderId] ?? 'data:image/png;base64,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',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(folder['name'], style: TextStyle(fontSize: 18)),
                        SizedBox(height: 4),
                        Text('Cards: ${_folderCardCounts[folderId] ?? 0}', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

