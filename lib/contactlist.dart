import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_contact_page.dart';
import 'update_contact_page.dart';
import 'sql_helper.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final CollectionReference contactsf =
  FirebaseFirestore.instance.collection('contacts');
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  int _isfavorited = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    List<Map<String, dynamic>> fetchedContacts = await dbHelper.getContacts();
    setState(() {
      contacts = fetchedContacts;
      _filteredContacts = contacts;
    });
  }

  void _addContact() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactPage(),
      ),
    );

    _getContacts();
  }

  void _updateContact(String contactId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateContactPage(contactId: contactId),
      ),
    );

    _getContacts();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (await Permission.phone.request().isGranted) {
      final url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      throw 'The CALL_PHONE permission is not granted.';
    }
  }

  void filterContacts(String query) {
    setState(() {
      _filteredContacts = contacts
          .where((contact) =>
      contact['tel']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          contact['nom']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          contact['prenom']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunch(launchUri.toString())) {
        await launch(launchUri.toString());
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      print('Error launching email client: $e');
      // Handle error, e.g., show an alert
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    ); // Return to the login page after logout
  }

  void _deleteContact(String contactId) async {
    WidgetsFlutterBinding.ensureInitialized();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Souhaitez-vous vraiment supprimer cet Contact?',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dbHelper.deleteContact(contactId);
              print('Deleted ');
              _getContacts();
            },
            child: Text(
              'SUPPRIMER',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'ANNULER',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String ContactId) async {
    setState(() {
      if (_isfavorited == 0) {
        _isfavorited = 1;
      } else {
        _isfavorited = 0;
      }
    });
    print(_isfavorited);
    await dbHelper.favorisContact(ContactId, _isfavorited);
    await _getContacts();
    filterContacts(searchController.text);
  }

  bool textFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0022CB),
        title: textFieldVisible
            ? Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            cursorColor: Colors.grey,
            controller: searchController,
            style: TextStyle(color: Colors.grey),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _getContacts();
                    textFieldVisible = false;
                    searchController.text = '';
                  });
                },
              ),
            ),
            onChanged: (String value) {
              print(value);
              filterContacts(value);
            },
          ),
        )
            : Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              'Contacts',
              style: TextStyle(
                color: Colors.white, // Set the text color to white
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          Visibility(
            visible: !textFieldVisible,
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  textFieldVisible = true;
                });
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredContacts.length,
        itemBuilder: (BuildContext context, int index) {
          String photoPath = _filteredContacts[index]['photo'];
          File imageFile = File(photoPath);
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: photoPath != ''
                  ? CircleAvatar(
                backgroundImage: FileImage(imageFile),
                radius: 24,
              )
                  : CircleAvatar(
                backgroundColor: Colors.greenAccent[400],
                child: Text(
                  _filteredContacts[index]['prenom'][0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                radius: 24,
              ),
              title: Text(
                '${_filteredContacts[index]['prenom']} ${_filteredContacts[index]['nom']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                _filteredContacts[index]['tel'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Color(0xFF650000),
                    ),
                    onPressed: () =>
                        _deleteContact(_filteredContacts[index]['id']),
                  ),
                  IconButton(
                    icon: _filteredContacts[index]['isfavorite'] == 0
                        ? Icon(
                      Icons.favorite,
                      color: Color(0xFFFF0000),
                    )
                        : Icon(Icons.favorite_border),
                    onPressed: () =>
                        _toggleFavorite((_filteredContacts[index]['id'])),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      Uri launchUri = Uri(
                        scheme: 'tel',
                        path: _filteredContacts[index]['tel'],
                      );
                      launchUrl(launchUri);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    onPressed: () =>
                        _sendEmail(_filteredContacts[index]['email']),
                  ),
                ],
              ),
              onTap: () =>
                  _updateContact(_filteredContacts[index]['id']),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: _addContact,
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: Colors.red, // or any color you prefer
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}