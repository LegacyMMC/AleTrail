import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PubInfoPage extends StatelessWidget {
  final String pubId;

  PubInfoPage({required this.pubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildSearchBar(),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('establishments').doc(pubId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Pub not found'));
          }

          var pubData = snapshot.data!.data() as Map<String, dynamic>;
          var pubName = pubData['name'] ?? "";
          var pubAddress = pubData['address'] ?? "";
          var pubImage = pubData['image'] ?? "";
          var pubDescription = pubData['description'] ?? '';
          var pubTags = pubData['tags'] ?? '';
          var pubDistance = pubData['distance'] ?? '<150M';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPubCard(pubImage, pubName, pubDescription, pubTags, pubDistance),
                _buildMenuSection(context, pubId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildPubCard(String pubImage, String pubName, String pubDescription, String pubTags, String pubDistance) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pubImage.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(pubImage, fit: BoxFit.cover, width: double.infinity, height: 150),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pubName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(pubDescription, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(pubTags, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(pubDistance, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String pubId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('establishments').doc(pubId).collection('menu').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No menu items found'));
        }

        var menuItems = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return MenuItem(
            name: data['name'],
            description: data['description'],
            price: data['price'],
            category: data['category'],
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Menu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMenuCategory('Beer', menuItems.where((item) => item.category == 'Beer').toList()),
              _buildMenuCategory('Spirits', menuItems.where((item) => item.category == 'Spirits').toList()),
              _buildMenuCategory('Cocktails', menuItems.where((item) => item.category == 'Cocktails').toList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCategory(String category, List<MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: ExpansionTile(
          title: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: items.map((item) => ListTile(
            title: Text(item.name),
            subtitle: Text(item.description),
            trailing: Text('\$${item.price.toStringAsFixed(2)}'),
          )).toList(),
        ),
      ),
    );
  }
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String category;

  MenuItem({required this.name, required this.description, required this.price, required this.category});
}