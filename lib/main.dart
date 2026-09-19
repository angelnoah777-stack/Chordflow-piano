import 'dart:math';
import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E5AA6),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Chord {
  final String name;
  final String notes;

  const Chord(this.name, this.notes);
}

const Map<String, List<Chord>> chordFamilies = {
  'C Major': [
    Chord('Cmaj7', 'C • E • G • B'),
    Chord('Dm7', 'D • F • A • C'),
    Chord('Em7', 'E • G • B • D'),
    Chord('Fmaj7', 'F • A • C • E'),
    Chord('G7', 'G • B • D • F'),
    Chord('Am7', 'A • C • E • G'),
    Chord('Bm7b5', 'B • D • F • A'),
  ],
  'G Major': [
    Chord('Gmaj7', 'G • B • D • F#'),
    Chord('Am7', 'A • C • E • G'),
    Chord('Bm7', 'B • D • F# • A'),
    Chord('Cmaj7', 'C • E • G • B'),
    Chord('D7', 'D • F# • A • C'),
    Chord('Em7', 'E • G • B • D'),
  ],
  'D Major': [
    Chord('Dmaj7', 'D • F# • A • C#'),
    Chord('Em7', 'E • G • B • D'),
    Chord('F#m7', 'F# • A • C# • E'),
    Chord('Gmaj7', 'G • B • D • F#'),
    Chord('A7', 'A • C# • E • G'),
    Chord('Bm7', 'B • D • F# • A'),
  ],
  'A Major': [
    Chord('Amaj7', 'A • C# • E • G#'),
    Chord('Bm7', 'B • D • F# • A'),
    Chord('C#m7', 'C# • E • G# • B'),
    Chord('Dmaj7', 'D • F# • A • C#'),
    Chord('E7', 'E • G# • B • D'),
    Chord('F#m7', 'F# • A • C# • E'),
  ],
};

const Map<String, List<List<String>>> beautifulProgressions = {
  'Worship': [
    ['Cmaj7', 'G', 'Am7', 'Fmaj7'],
    ['C', 'Am7', 'Fmaj7', 'G'],
    ['G', 'D', 'Em7', 'Cmaj7'],
    ['Cmaj7', 'Fmaj7', 'Am7', 'G'],
  ],
  'Gospel': [
    ['Cmaj7', 'Am7', 'Dm7', 'G7'],
    ['Cmaj7', 'Em7', 'Am7', 'Fmaj7'],
    ['Fmaj7', 'G7', 'Em7', 'Am7'],
  ],
  'Jazz': [
    ['Cmaj7', 'A7', 'Dm7', 'G7'],
    ['Dm7', 'G7', 'Cmaj7', 'A7'],
    ['Cmaj7', 'Am7', 'Dm7', 'G7'],
  ],
  'Romantic': [
    ['Cmaj7', 'Am7', 'Fmaj7', 'G7'],
    ['Fmaj7', 'G', 'Em7', 'Am7'],
    ['Cmaj7', 'Em7', 'Fmaj7', 'G'],
  ],
  'Dreamy': [
    ['Cmaj7', 'Em7', 'Am7', 'Fmaj7'],
    ['Am7', 'Fmaj7', 'Cmaj7', 'G'],
    ['Cmaj7', 'G', 'Em7', 'Am7'],
  ],
  'Emotional': [
    ['Am7', 'Fmaj7', 'Cmaj7', 'G'],
    ['Em7', 'Am7', 'Fmaj7', 'Cmaj7'],
    ['Am7', 'Dm7', 'G7', 'Cmaj7'],
  ],
  'Pop': [
    ['C', 'G', 'Am', 'F'],
    ['G', 'D', 'Em', 'C'],
    ['C', 'Am', 'F', 'G'],
  ],
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  final List<String> tabs = [
    'Explore',
    'Families',
    'Generator',
    'Piano',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChordFlow 🎹',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: tab,
        children: const [
          ExplorePage(),
          FamiliesPage(),
          GeneratorPage(),
          PianoPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() => tab = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Families',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Generate',
          ),
          NavigationDestination(
            icon: Icon(Icons.piano_outlined),
            selectedIcon: Icon(Icons.piano),
            label: 'Piano',
          ),
        ],
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Beautiful chords.\nBeautiful music.',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover chord families and beautiful progressions.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('✨ Beautiful combinations'),
        const SizedBox(height: 12),
        ...[
          ['Cmaj7', 'Am7', 'Fmaj7', 'G7'],
          ['Cmaj7', 'Em7', 'Am7', 'Fmaj7'],
          ['Am7', 'Fmaj7', 'Cmaj7', 'G'],
        ].map(
          (progression) => ProgressionCard(progression: progression),
        ),
        const SizedBox(height: 18),
        const SectionTitle('🎵 Explore by mood'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: beautifulProgressions.keys.map((mood) {
            return ActionChip(
              label: Text(mood),
              onPressed: () {},
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FamiliesPage extends StatefulWidget {
  const FamiliesPage({super.key});

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  String selectedKey = 'C Major';

  @override
  Widget build(BuildContext context) {
    final chords = chordFamilies[selectedKey]!;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Chord Families',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedKey,
          decoration: const InputDecoration(
            labelText: 'Choose a key',
            border: OutlineInputBorder(),
          ),
          items: chordFamilies.keys.map((key) {
            return DropdownMenuItem(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedKey = value);
            }
          },
        ),
        const SizedBox(height: 20),
        ...chords.map(
          (chord) => Card(
            child: ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(
                chord.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(chord.notes),
              trailing: const Icon(Icons.play_arrow),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  String mood = 'Worship';
  List<String> current = beautifulProgressions['Worship']!.first;

  void generate() {
    final list = beautifulProgressions[mood]!;
    setState(() {
      current = list[Random().nextInt(list.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          '✨ Progression Generator',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a mood and let ChordFlow create a beautiful progression.',
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: mood,
          decoration: const InputDecoration(
            labelText: 'Mood / Style',
            border: OutlineInputBorder(),
          ),
          items: beautifulProgressions.keys.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => mood = value);
            }
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  mood.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: current.map((chord) {
                    return Chip(
                      label: Text(
                        chord,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate beautiful progression'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PianoPage extends StatefulWidget {
  const PianoPage({super.key});

  @override
  State<PianoPage> createState() => _PianoPageState();
}

class _PianoPageState extends State<PianoPage> {
  final Set<String> selected = {};

  final List<String> notes = [
    'C',
    'D',
    'E',
    'F',
    'G',
    'A',
    'B',
  ];

  void toggle(String note) {
    setState(() {
      if (selected.contains(note)) {
        selected.remove(note);
      } else {
        selected.add(note);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          '🎹 Piano',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Tap notes to create your own chord.'),
        const SizedBox(height: 24),
        SizedBox(
          height: 280,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: notes.map((note) {
              final active = selected.contains(note);

              return Expanded(
                child: GestureDetector(
                  onTap: () => toggle(note),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                          : Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              selected.isEmpty
                  ? 'Selected notes: —'
                  : 'Selected notes: ${selected.join(' • ')}',
              style: const TextStyle(fontSize: 17),
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressionCard extends StatelessWidget {
  final List<String> progression;

  const ProgressionCard({
    super.key,
    required this.progression,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: progression.map((chord) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    chord,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
