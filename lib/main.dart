import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Note {
  String title;
  String content;

  Note({required this.title, required this.content});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
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

  void _addNote(String title, String content) {
    setState(() {
      _notes.add(Note(title: title, content: content));
    });
  }

  void _removeNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                selectedIcon: Icon(Icons.person_outline, color: Colors.red),
                label: Text('Usuario'),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                NotesListScreen(notes: _notes, onDelete: _removeNote),
                NewNoteScreen(onAddNote: _addNote),
                UserInfoScreen(),
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
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Notas')),
      body: notes.isEmpty
          ? Center(
              child: Text('No hay notas guardadas.',
                  style: TextStyle(fontSize: 18)))
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(notes[index].title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notes[index].content),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NewNoteScreen extends StatefulWidget {
  final Function(String, String) onAddNote;

  NewNoteScreen({required this.onAddNote});

  @override
  _NewNoteScreenState createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _saveNote() {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      widget.onAddNote(_titleController.text, _contentController.text);
      _titleController.clear();
      _contentController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nota guardada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Nota')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                  labelText: 'Contenido', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child:
                  Text('Guardar Nota', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Información del Usuario')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 10),
            Text('Nombre: Christian Vasquez',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Email: Chrisss.Vas@example.com',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
