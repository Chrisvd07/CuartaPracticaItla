import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
    );
  }
}

class Profile {
  String name;
  String description;

  Profile({required this.name, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  static Profile fromMap(Map<String, dynamic> map) {
    return Profile(
      name: map['name'],
      description: map['description'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Notas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Note> _notes = [];
  Profile _profile = Profile(
    name: 'Christian Vasquez',
    description: 'Desarrollador de Flutter',
  );

  @override
  void initState() {
    super.initState();
    _loadNotes(); 
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList('notes');
    if (notesJson != null) {
      setState(() {
        _notes = notesJson.map((note) {
          Map<String, dynamic> noteMap = json.decode(note);
          return Note.fromMap(noteMap);
        }).toList();
      });
    }
  }

  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson =
        _notes.map((note) => json.encode(note.toMap())).toList();
    prefs.setStringList('notes', notesJson);
  }

  void _addNote(String title, String content) async {
    setState(() {
      _notes.add(Note(title: title, content: content)); 
    });
    _saveNotes(); 
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Nota guardada')));
  }

  
  void _removeNote(int index) {
    setState(() {
      _notes.removeAt(index); 
    });
    _saveNotes(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Notas')),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.deepPurple.shade100,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list_alt, color: Colors.red),
                label: Text('Notas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                selectedIcon: Icon(Icons.note_add, color: Colors.red),
                label: Text('Nueva Nota'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person_pin, color: Colors.red),
                label: Text('Perfil'),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                NotesListScreen(notes: _notes, onDelete: _removeNote),
                NewNoteScreen(onAddNote: _addNote),
                ProfileScreen(profile: _profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotesListScreen extends StatelessWidget {
  final List<Note> notes;
  final Function(int) onDelete;

  NotesListScreen({required this.notes, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(notes[index].title),
          subtitle: Text(notes[index].content),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onDelete(index), 
          ),
        );
      },
    );
  }
}

class NewNoteScreen extends StatelessWidget {
  final Function(String, String) onAddNote;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  NewNoteScreen({required this.onAddNote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Título de la nota'),
          ),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Contenido de la nota'),
          ),
          ElevatedButton(
            onPressed: () {
              String title = _titleController.text;
              String content = _contentController.text;
              if (title.isNotEmpty && content.isNotEmpty) {
                onAddNote(title, content); 
                _titleController.clear();
                _contentController.clear();
              }
            },
            child: Text('Guardar Nota'),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final Profile profile;

  ProfileScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.green.shade50,
              Colors.yellow.shade50
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    profile.name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile.description,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        "99",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        ["SQL", "C++", "C#", "VB", "JavaScript"].map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Contactar"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                        ),
                        child: Text("CV"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text("25",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Proyectos"),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.people, color: Colors.blue),
                          Text("2.4K",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Seguidores"),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.thumb_up, color: Colors.red),
                          Text("5.0",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rating"),
                        ],
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
