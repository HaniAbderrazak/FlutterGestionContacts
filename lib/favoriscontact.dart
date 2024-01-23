import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gest_contacts/sql_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class favorisContact extends StatefulWidget {
  const favorisContact({Key? key}) : super(key: key);

  @override
  State<favorisContact> createState() => _favorisContactState();
}

class _favorisContactState extends State<favorisContact> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> favorisContacts = [];
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  bool textFieldVisible = false;

  @override
  void initState() {
    super.initState();
    getFavoris();
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

  void getFavoris() async {
    favorisContacts = await dbHelper.getFavoris();
    setState(() {
      contacts = favorisContacts;
      _filteredContacts = contacts;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    ); // Return to the login page after logout
  }

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
            cursorColor: Colors.black,
            controller: searchController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    getFavoris();
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
          child: Text(
            'Favoris',
            style: TextStyle(
              color: Colors.white, // Set the text color to white
              fontWeight: FontWeight.bold,
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
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: photoPath != ''
                  ? CircleAvatar(
                backgroundImage: FileImage(imageFile),
                radius: 24,
              )
                  : CircleAvatar(
                backgroundColor: Colors.green[400],
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
                  fontSize: 16,
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
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.logout, color: Colors.white),
        onPressed: _logout,
      ),
    );
  }
}
