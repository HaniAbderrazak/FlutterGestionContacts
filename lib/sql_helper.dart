import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  // CRUD methods

  Future<void> insertContact(Map<String, dynamic> contact) async {
    await FirebaseFirestore.instance.collection('contacts').add(contact);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('contacts').get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID in the map
      return data;
    }).toList();
  }

  Future<void> updateContact(Map<String, dynamic> contact) async {
    String docId = contact['id'];

    await FirebaseFirestore.instance
        .collection('contacts')
        .doc(docId)
        .update(contact);
  }

  Future<void> favorisContact(String id, int favoris) async {
    await FirebaseFirestore.instance
        .collection('contacts')
        .doc(id)
        .update({'isfavorite': favoris});
  }

  Future<List<Map<String, dynamic>>> getFavoris() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('contacts')
        .where('isfavorite', isEqualTo: 0)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID in the map
      return data;
    }).toList();
  }


  Future<void> deleteContact(String id) async {
    print(id);
    await FirebaseFirestore.instance
        .collection('contacts')
        .doc(id)
        .delete();
  }

  Future<Map<String, dynamic>> getContactById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await FirebaseFirestore.instance
        .collection('contacts')
        .doc(id.toString())
        .get();

    return documentSnapshot.data() ?? {};
  }
}
