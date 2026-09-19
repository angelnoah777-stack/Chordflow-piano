import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
          seedColor: const Color(0xFF6558D3),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Chord {
  final String name;
  final List<int> notes;

  const Chord(this.name, this.notes);
}

const List<Chord> chords = [
  Chord('Cmaj7', [60, 64, 67, 71]),
  Chord('Am7', [57, 60, 64, 67]),
  Chord('Fmaj7', [53, 57, 60, 64]),
  Chord('G7', [55, 59, 62, 65]),
  Chord('Dm7', [50, 53, 57, 60]),
  Chord('Cadd9', [60, 64, 67, 74]),
  Chord('Gsus4', [55, 60, 62, 67]),
  Chord('Em7', [52, 55, 59, 62]),
];

class AudioEngine {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playChord(List<int> midiNotes) async {
    final bytes = _createWav(midiNotes);

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/chordflow_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    await file.writeAsBytes(bytes, flush: true);

    await _player.stop();
    await _player.play(DeviceFileSource(file.path));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  double _frequency(int midi) {
    return 440.0 * pow(2, (midi - 69) / 12);
  }

  Uint8List _createWav(List<int> midiNotes) {
    const sampleRate = 44100;
    const duration = 1.8;

    final sampleCount = (sampleRate * duration).toInt();
    final dataSize = sampleCount * 2;

    final output = BytesBuilder();

    // WAV header
    output.add(_ascii('RIFF'));
    _writeInt32(output, 36 + dataSize);
    output.add(_ascii('WAVE'));

    output.add(_ascii('fmt '));
    _writeInt32(output, 16);
    _writeInt16(output, 1);
    _writeInt16(output, 1);
    _writeInt32(output, sampleRate);
    _writeInt32(output, sampleRate * 2);
    _writeInt16(output, 2);
    _writeInt16(output, 16);

    output.add(_ascii('data'));
    _writeInt32(output, dataSize);

    for (int i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;

      double sample = 0;

      for (final midi in midiNotes) {
        final frequency = _frequency(midi);

        // Fundamental + harmonics for a warmer piano-like sound.
        sample += sin(2 * pi * frequency * t);
        sample += 0.28 * sin(2 * pi * frequency * 2 * t);
        sample += 0.12 * sin(2 * pi * frequency * 3 * t);
      }

      sample /= midiNotes.length;

      // Envelope
      double envelope;

      if (t < 0.04) {
        envelope = t / 0.04;
      } else if (t < 0.18) {
        envelope = 1.0 - ((t - 0.04) / 0.14) * 0.25;
      } else {
        envelope = 0.75 * exp(-(t - 0.18) * 1.4);
      }

      sample *= envelope;
      sample *= 0.55;

      sample = sample.clamp(-1.0, 1.0);

      final value = (sample * 32767).round();

      _writeInt16(output, value);
    }

    return output.toBytes();
  }

  Uint8List _ascii(String text) {
    return Uint8List.fromList(text.codeUnits);
  }

  void _writeInt16(BytesBuilder builder, int value) {
    final data = ByteData(2);
    data.setInt16(0, value, Endian.little);
    builder.add(data.buffer.asUint8List());
  }

  void _writeInt32(BytesBuilder builder, int value) {
    final data = ByteData(4);
    data.setInt32(0, value, Endian.little);
    builder.add(data.buffer.asUint8List());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioEngine audio = AudioEngine();

  int selectedTab = 0;

  String currentChord = 'Cmaj7';

  List<Chord> generatedProgression = [
    chords[0],
    chords[1],
    chords[2],
    chords[3],
  ];

  final Random random = Random();

  Future<void> playChord(Chord chord) async {
    setState(() {
      currentChord = chord.name;
    });

    await audio.playChord(chord.notes);
  }

  void generateProgression() {
    setState(() {
      generatedProgression = List.generate(
        4,
        (_) => chords[random.nextInt(chords.length)],
      );

      currentChord = generatedProgression.first.name;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ New beautiful progression generated!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget chordButton(Chord chord) {
    final selected = currentChord == chord.name;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => playChord(chord),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6558D3)
              : Colors.deepPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              Icons.music_note,
              color: selected ? Colors.white : Colors.deepPurple,
            ),
            const SizedBox(height: 6),
            Text(
              chord.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExplore() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'ChordFlow 🎹',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Beautiful chords. Beautiful music.',
          style: TextStyle(
            fontSize: 17,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap any chord to hear it.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),

        const Text(
          '✨ Beautiful combinations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: chords.map(chordButton).toList(),
        ),

        const SizedBox(height: 28),

        const Text(
          '🎵 Current chord',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6558D3),
                Color(0xFF8B7FE8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                currentChord,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the chord buttons above to play',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  final chord = chords.firstWhere(
                    (c) => c.name == currentChord,
                  );
                  playChord(chord);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          '🎼 Popular moods',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Worship',
            'Gospel',
            'Jazz',
            'Romantic',
            'Dreamy',
            'Emotional',
            'Pop',
          ].map(
            (mood) => ActionChip(
              label: Text(mood),
              onPressed: () {
                generateProgression();
              },
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget buildFamilies() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          '🎼 Chord Families',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explore chords that naturally belong together.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),

        _familyCard(
          'C Major Family',
          [
            chords[0],
            chords[1],
            chords[2],
            chords[3],
          ],
        ),

        _familyCard(
          'Gospel Family',
          [
            chords[1],
            chords[4],
            chords[2],
            chords[3],
          ],
        ),

        _familyCard(
          'Dreamy Family',
          [
            chords[0],
            chords[7],
            chords[1],
            chords[2],
          ],
        ),
      ],
    );
  }

  Widget _familyCard(String title, List<Chord> family) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: family.map(
                (chord) => ActionChip(
                  label: Text(chord.name),
                  onPressed: () => playChord(chord),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGenerate() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          '✨ Generate',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a beautiful chord progression instantly.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 30),

        FilledButton.icon(
          onPressed: generateProgression,
          icon: const Icon(Icons.auto_awesome),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Generate Progression',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),

        const SizedBox(height: 25),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text(
                  'Your progression',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                ...generatedProgression.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final chord = entry.value;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        chord.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => playChord(chord),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                FilledButton.icon(
                  onPressed: () async {
                    for (final chord in generatedProgression) {
                      await playChord(chord);
                      await Future.delayed(
                        const Duration(milliseconds: 1700),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Play Progression'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPiano() {
    final pianoNotes = [
      {'name': 'C', 'midi': 60},
      {'name': 'D', 'midi': 62},
      {'name': 'E', 'midi': 64},
      {'name': 'F', 'midi': 65},
      {'name': 'G', 'midi': 67},
      {'name': 'A', 'midi': 69},
      {'name': 'B', 'midi': 71},
      {'name': 'C', 'midi': 72},
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          '🎹 Piano',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap a key to play a note.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 35),

        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: pianoNotes.map((note) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () {
                      audio.playChord([note['midi'] as int]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 5,
                            offset: Offset(0, 3),
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        note['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget currentPage() {
    switch (selectedTab) {
      case 1:
        return buildFamilies();
      case 2:
        return buildGenerate();
      case 3:
        return buildPiano();
      default:
        return buildExplore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: currentPage(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music),
            label: 'Families',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Generate',
          ),
          NavigationDestination(
            icon: Icon(Icons.piano),
            label: 'Piano',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audio.stop();
    super.dispose();
  }
}
