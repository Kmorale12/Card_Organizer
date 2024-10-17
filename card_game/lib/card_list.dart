import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardListScreen extends StatefulWidget {
  final int folderId;

  CardListScreen({required this.folderId});

  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _cards = [];

  

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  _fetchCards() async {
    final cards = await dbHelper.getCardsByFolder(widget.folderId);
    setState(() {
      _cards = cards;
    });
  }

  _addCard() async {
    // Logic to add a new card (this can open a form)
    await dbHelper.insertCard({
      'name': 'New Card',
      'suit': 'Spades',
      'imageUrl': 'https://example.com/new_card.png',
      'folderId': widget.folderId,
    });
    _fetchCards();
  }

 

  _updateCard(Map<String, dynamic> card) async {
    // Logic to update the card (this can open a form to edit card details)
    card['name'] = 'Updated Card';
    await dbHelper.updateCard(card);
    _fetchCards();
  }

  _deleteCard(int id) async {
    await dbHelper.deleteCard(id);
    _fetchCards();
  }

  @override
  Widget build(BuildContext context) {

    
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards in Folder'),
        actions: [
          IconButton(
            onPressed: _addCard, 
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _cards.isNotEmpty
          ? GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display two cards per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return GestureDetector(
                  onTap: () => _updateCard(card), // Tap to update card
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            card['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(card['name'], style: TextStyle(fontSize: 16)),
                              Text(card['suit'], style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCard(card['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('No cards in this folder'),
            ),
    );
  }
}
