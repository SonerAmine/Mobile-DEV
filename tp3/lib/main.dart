import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService(); // pour Exercice 2 & 3
  runApp(const MyApp());
}

// ═══════════════════════════════════════════════════════════════════════════
//  BACKGROUND SERVICE (Exercice 2 & 3)
// ═══════════════════════════════════════════════════════════════════════════

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'tp3_channel',
      initialNotificationTitle: '🎵 Lecteur Audio',
      initialNotificationContent: 'En attente...',
      foregroundServiceNotificationId: 999,
      foregroundServiceTypes: const [AndroidForegroundType.mediaPlayback],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// Callback du service — tourne en arrière-plan (isolate séparé : enregistrer les plugins)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  log('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

  AudioPlayer? player;

  // Exercice 2 : arrêter le service
  service.on('stopService').listen((_) {
    player?.dispose();
    service.stopSelf(); // service.stopSelf()
  });

  // Exercice 3 : lancer la lecture avec infos
  service.on('playAudio').listen((data) async {
    final String title  = data?['title']  ?? 'Inconnu';
    final String artist = data?['artist'] ?? 'Inconnu';

    // Mise à jour notification avec infos audio
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: '🎵 $title',
        content: '👤 $artist — En lecture...',
      );
    }

    player?.dispose();
    player = AudioPlayer();
    await player!.setAsset('sounds/music.mp3');
    player!.play();

    service.invoke('audioInfo', {
      'title': title,
      'artist': artist,
      'status': 'En lecture',
    });

    // Mise à jour de la position en temps réel dans la notification
    player!.positionStream.listen((pos) {
      if (service is AndroidServiceInstance) {
        final mm = pos.inMinutes.toString().padLeft(2, '0');
        final ss = (pos.inSeconds % 60).toString().padLeft(2, '0');
        service.setForegroundNotificationInfo(
          title: '🎵 $title',
          content: '👤 $artist  ⏱ $mm:$ss',
        );
      }
    });
  });

  service.on('pause').listen((_) {
    player?.pause();
    service.invoke('audioInfo', {'status': 'En pause'});
  });

  service.on('resume').listen((_) {
    player?.play();
    service.invoke('audioInfo', {'status': 'En lecture'});
  });
}

// ═══════════════════════════════════════════════════════════════════════════
//  APPLICATION PRINCIPALE
// ═══════════════════════════════════════════════════════════════════════════

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TP3 - Audio & Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Exercice1Page(),
    Exercice2Page(),
    Exercice3Page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Exercice 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: 'Exercice 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Exercice 3',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EXERCICE 1 — Lecture audio simple avec just_audio
// ═══════════════════════════════════════════════════════════════════════════

// Fonction sound() demandée dans l'exercice 1
Future<void> sound() async {
  final AudioPlayer _player = AudioPlayer();
  await _player.setAudioSource(
    AudioSource.uri(Uri.parse('sounds/music.mp3')),
  );
  _player.play();
}

class Exercice1Page extends StatefulWidget {
  const Exercice1Page({super.key});

  @override
  State<Exercice1Page> createState() => _Exercice1PageState();
}

class _Exercice1PageState extends State<Exercice1Page> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _play() async {
    await _player.setAsset('sounds/music.mp3');
    _player.play();
    setState(() => _isPlaying = true);
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercice 1 — just_audio'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.graphic_eq : Icons.music_note,
              size: 100,
              color: Colors.indigo,
            ),
            const SizedBox(height: 20),
            Text(
              _isPlaying ? '🎵 En lecture...' : 'Prêt',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isPlaying ? null : _play,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Lancer l\'audio'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isPlaying ? _stop : null,
              icon: const Icon(Icons.stop),
              label: const Text('Arrêter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EXERCICE 2 — Background Service
// ═══════════════════════════════════════════════════════════════════════════

class Exercice2Page extends StatefulWidget {
  const Exercice2Page({super.key});

  @override
  State<Exercice2Page> createState() => _Exercice2PageState();
}

class _Exercice2PageState extends State<Exercice2Page> {
  final _service = FlutterBackgroundService();
  bool _running = false;

  Future<void> _startService() async {
    _service.startService();
    setState(() => _running = true);
  }

  void _stopService() {
    _service.invoke('stopService'); // déclenche service.stopSelf()
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercice 2 — Background Service'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _running ? Icons.cloud_done : Icons.cloud_off,
              size: 100,
              color: _running ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _running ? 'Service actif' : 'Service arrêté',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              _running ? 'Vérifiez le log : FLUTTER BACKGROUND SERVICE' : '',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _running ? null : _startService,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer le service'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _running ? _stopService : null,
              icon: const Icon(Icons.stop),
              label: const Text('Arrêter le service (stopSelf)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EXERCICE 3 — Service + Notification avec infos audio
// ═══════════════════════════════════════════════════════════════════════════

class Exercice3Page extends StatefulWidget {
  const Exercice3Page({super.key});

  @override
  State<Exercice3Page> createState() => _Exercice3PageState();
}

class _Exercice3PageState extends State<Exercice3Page> {
  final _service = FlutterBackgroundService();

  String _title  = '—';
  String _artist = '—';
  String _status = 'Arrêté';
  bool   _running = false;
  int    _selectedTrack = 0;

  final List<Map<String, String>> _tracks = [
    {'title': 'Music One',   'artist': 'Artiste A'},
    {'title': 'Music Two',   'artist': 'Artiste B'},
    {'title': 'Music Three', 'artist': 'Artiste C'},
  ];

  @override
  void initState() {
    super.initState();
    // Écoute les infos renvoyées par le service
    _service.on('audioInfo').listen((data) {
      if (data != null && mounted) {
        setState(() {
          _title  = data['title']  ?? _title;
          _artist = data['artist'] ?? _artist;
          _status = data['status'] ?? _status;
        });
      }
    });
  }

  Future<void> _play() async {
    if (!_running) {
      _service.startService();
      setState(() => _running = true);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final track = _tracks[_selectedTrack];
    _service.invoke('playAudio', {
      'title':  track['title']!,
      'artist': track['artist']!,
    });
    setState(() {
      _title  = track['title']!;
      _artist = track['artist']!;
      _status = 'En lecture';
    });
  }

  void _pause()  => _service.invoke('pause');
  void _resume() => _service.invoke('resume');

  void _stop() {
    _service.invoke('stopService');
    setState(() {
      _running = false;
      _status  = 'Arrêté';
      _title   = '—';
      _artist  = '—';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercice 3 — Media + Notification'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Carte infos audio ─────────────────────────────────────────
            Card(
              color: Colors.indigo.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.music_note, size: 60, color: Colors.indigo),
                    const SizedBox(height: 8),
                    Text(_title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(_artist,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(_status),
                      backgroundColor: _status == 'En lecture'
                          ? Colors.green.shade100
                          : _status == 'En pause'
                          ? Colors.orange.shade100
                          : Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Sélection du morceau ──────────────────────────────────────
            const Text('Choisir un morceau :',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._tracks.asMap().entries.map((e) => RadioListTile<int>(
              title: Text('${e.value['title']} — ${e.value['artist']}'),
              value: e.key,
              groupValue: _selectedTrack,
              onChanged: (v) => setState(() => _selectedTrack = v!),
            )),

            const SizedBox(height: 20),

            // ── Contrôles ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlBtn(Icons.play_arrow, 'Lire',    Colors.indigo, _play),
                _controlBtn(Icons.pause,      'Pause',   Colors.orange,
                    _status == 'En lecture' ? _pause : null),
                _controlBtn(Icons.play_circle,'Reprendre',Colors.green,
                    _status == 'En pause' ? _resume : null),
                _controlBtn(Icons.stop,       'Stop',    Colors.red,
                    _running ? _stop : null),
              ],
            ),

            const SizedBox(height: 20),

            // ── Statut service ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle,
                    size: 12,
                    color: _running ? Colors.green : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _running ? 'Service actif — notification visible' : 'Service arrêté',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn(
      IconData icon, String label, Color color, VoidCallback? onPressed) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          style: IconButton.styleFrom(backgroundColor: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}