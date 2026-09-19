import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ChordFlowApp());
}

class ChordFlowApp extends StatelessWidget {
  const ChordFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChordFlow Piano',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5BD6)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Chord {
  final String name;
  final List<String> notes;
  const Chord(this.name, this.notes);
}

const chords = <Chord>[
  Chord('Cmaj7', ['C', 'E', 'G', 'B']),
  Chord('Am7', ['A', 'C', 'E', 'G']),
  Chord('Fmaj7', ['F', 'A', 'C', 'E']),
  Chord('G7', ['G', 'B', 'D', 'F']),
  Chord('Dm7', ['D', 'F', 'A', 'C']),
  Chord('Cadd9', ['C', 'E', 'G', 'D']),
  Chord('Gsus4', ['G', 'C', 'D']),
  Chord('Em7', ['E', 'G', 'B', 'D']),
];

const progressions = <List<String>>[
  ['Cmaj7', 'Am7', 'Fmaj7', 'G7'],
  ['Cmaj7', 'G7', 'Am7', 'Fmaj7'],
  ['Dm7', 'G7', 'Cmaj7', 'Am7'],
  ['Cadd9', 'Gsus4', 'Am7', 'Fmaj7'],
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedChord = 'Cmaj7';
  List<String> currentProgression = progressions.first;
  final Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => favorites.addAll(prefs.getStringList('favorites') ?? []));
  }

  Future<void> _toggleFavorite(String chord) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!favorites.add(chord)) favorites.remove(chord);
    });
    await prefs.setStringList('favorites', favorites.toList());
  }

  Chord get current =>
      chords.firstWhere((c) => c.name == selectedChord, orElse: () => chords.first);

  void _generate() {
    final next = progressions[
        DateTime.now().millisecondsSinceEpoch % progressions.length];
    setState(() {
      currentProgression = next;
      selectedChord = next.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChordFlow 🎹'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => _showFavorites(context),
            icon: const Icon(Icons.favorite_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Beautiful chords. Beautiful music.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT CHORD'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            current.name,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleFavorite(current.name),
                          icon: Icon(
                            favorites.contains(current.name)
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                        ),
                      ],
                    ),
                    Text(current.notes.join(' · ')),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chords.map((chord) {
                        return ChoiceChip(
                          label: Text(chord.name),
                          selected: selectedChord == chord.name,
                          onSelected: (_) =>
                              setState(() => selectedChord = chord.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BEAUTIFUL PROGRESSION'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: currentProgression.map((name) {
                        return ActionChip(
                          label: Text(name),
                          onPressed: () =>
                              setState(() => selectedChord = name),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate progression'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PIANO'),
                    const SizedBox(height: 12),
                    PianoKeyboard(notes: current.notes),
                    const SizedBox(height: 10),
                    Text(
                      'Selected notes: ${current.notes.join(' · ')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: favorites.isEmpty
              ? const Text('No favorites yet.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: favorites
                      .map((name) => ActionChip(
                            label: Text(name),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() => selectedChord = name);
                            },
                          ))
                      .toList(),
                ),
        ),
      ),
    );
  }
}

class PianoKeyboard extends StatelessWidget {
  final List<String> notes;
  const PianoKeyboard({super.key, required this.notes});

  static const keys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((note) {
          final active = notes.contains(note);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.white,
                border: Border.all(color: Colors.black26),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(note),
            ),
          );
        }).toList(),
      ),
    );
  }
}
