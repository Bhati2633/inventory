// inventory_home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'inventory_add_page.dart';

class InventoryHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!.docs;
          return items.isEmpty
              ? Center(child: Text('No items in inventory', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      color: Colors.grey[850],
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      child: ListTile(
                        title: Text(item['name'], style: TextStyle(color: Colors.white)),
                        subtitle: Text('Quantity: ${item['quantity']}', style: TextStyle(color: Colors.white70)),
                        trailing: Icon(Icons.edit, color: Colors.deepPurpleAccent),
                        onTap: () {
                          _showEditDialog(context, item.id, item['name'], item['quantity']);
                        },
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InventoryAddPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String itemId, String currentName, int currentQuantity) {
    final _formKey = GlobalKey<FormState>();
    String updatedName = currentName;
    int updatedQuantity = currentQuantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Edit Item', style: TextStyle(color: Colors.white)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: currentName,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Item Name', labelStyle: TextStyle(color: Colors.white70)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    updatedName = value;
                  },
                ),
                TextFormField(
                  initialValue: currentQuantity.toString(),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Quantity', labelStyle: TextStyle(color: Colors.white70)),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    updatedQuantity = int.tryParse(value) ?? currentQuantity;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await FirebaseFirestore.instance.collection('inventory').doc(itemId).update({
                    'name': updatedName,
                    'quantity': updatedQuantity,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update', style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('inventory').doc(itemId).delete();
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
