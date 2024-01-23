import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gest_contacts/sql_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class AddContactPage extends StatefulWidget {
  @override
  _AddContactPageState createState() => _AddContactPageState();
}
class _AddContactPageState extends State<AddContactPage> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {

      Map<String, dynamic> newContact = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'tel': _telController.text,
        'photo': _selectedImage != null ? _selectedImage!.path : '',
        'email': _emailController.text,

      };

      await  FirebaseFirestore.instance.collection('contacts').add(newContact);
      Navigator.pop(context);
    }


  }
  void _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Widget _buildImage() {
    if (_selectedImage != null) {
      return GestureDetector(
        child: CircleAvatar(backgroundImage: FileImage(_selectedImage!),
        radius: 60,),
        onTap: _selectImage,
      );
    } else {
      return CircleAvatar(child: IconButton(
        icon: Icon(Icons.add_photo_alternate_outlined ),
        onPressed: _selectImage,
        color: Colors.black,
        iconSize: 40,
      ),
      backgroundColor: Colors.lightBlue[200],
      radius: 60,);
    }
  }

  Widget _buildSelectImageButton() {
    return _selectedImage != null ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            side: MaterialStateProperty.all(BorderSide.none),
            elevation: MaterialStateProperty.all(0.0),
          ),
          onPressed: _selectImage,
          child: Text(
            'Modifier',
            style: TextStyle(color: Colors.blue[800]),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            side: MaterialStateProperty.all(BorderSide.none),
            elevation: MaterialStateProperty.all(0.0),
          ),
          onPressed: () {
            setState(() {
              _selectedImage = null;
            });
          },
          child: Text(
            'Supprimer',
            style: TextStyle(color: Colors.blue[800]),
          ),
        ),
      ],
    )
        : ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        side: MaterialStateProperty.all(BorderSide.none),
        elevation: MaterialStateProperty.all(0.0),
      ),
      onPressed: _selectImage,
      child: Text(
        'Ajouter une image',
        style: TextStyle(color: Colors.blue,
        fontSize: 30
        ),

      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return


      Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            color: Colors.grey[700],
            icon: Icon(Icons.clear),
            onPressed: (){
Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          title: Text('Créer un contact',style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,),
        ),
        body: Container(
          color: Colors.white,
          height: double.infinity,

          child: SingleChildScrollView(
            child: Padding(
            padding: EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            SizedBox(height: 50,),
            _buildImage(),
            _buildSelectImageButton(),
              Row(children: [
                Icon(Icons.person_outlined,color: Colors.grey, ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      hintText: 'Nom',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),

                    ),
                  validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      if (value.length > 15) {
                        return 'Le nom ne peut pas dépasser 15 caractères';
                      }
                      return null;
                    },
                  ),
                ),
              ],),
            SizedBox(height: 15),
            Row(children: [
              Icon(Icons.person_outlined,color: Colors.grey, ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(
                    hintText: 'Prénom',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),

                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    if (value.length > 15) {
                      return 'Le prénom ne peut pas dépasser 15 caractères';
                    }
                    return null;
                  },
                ),
              ),
            ],),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.email, color: Colors.grey),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'email',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!emailRegex.hasMatch(value)) {
                      return 'Veuillez entrer une adresse email valide';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 15),
            Row(children: [
              Icon(Icons.call,color: Colors.grey, ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _telController,
                  decoration: InputDecoration(
                    hintText: 'Téléphone',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),

                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez saisir votre numéro de téléphone';
                    }
                    if (value.length > 15) {
                      return 'Le numéro de téléphone ne peut pas dépasser 15 chiffres';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],),
              SizedBox(height: 16.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>( Color(
                      0xFF00219A)!),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(30, 50), // Adjust width and height
                  ),
                ),
                onPressed: _saveContact,
                child: Text(
                  'Enregistrer',
                  style: TextStyle(
                    color: Colors.white, // Text color of the button
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Color(
                      0xFF00219A)!),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(100, 50), // Adjust width and height
                  ),
                ),

                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: Colors.white, // Text color of the button
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    ),
            ),
          ),
        ),
    );
  }
}