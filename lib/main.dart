import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_time/time.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadAllData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '勉強時間',
      initialRoute: '/',
      routes: {
        '/':(context) => MainPage(),
        '/home': (context) => HomeScreen(),
        '/add':(context) => AddScreen(),
        '/record': (context) => RecordScreen(),
        '/timer':(context) => TimerScreen(),
        '/type':(context) => TypeScreen(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[350],
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: const Color.fromARGB(255, 139, 203, 255),
              width: 2.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const RecordScreen(),
      const HomeScreen(),
      const AddScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 41, 142, 255),
        unselectedItemColor: Colors.grey[360],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '記録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '追加',
          )
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 65,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/timer');
                    },
                    child: const Text('測定')
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                SizedBox(
                  height: 65,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/type');
                    }, child: const Text('入力'),
                  ),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  bool subject = true;
  String? _selectedSubject = '数学';

  void _addSubjectDialog () {
    final TextEditingController textController = TextEditingController();
    String? _errorMessage;

    showDialog(
      context: context, builder: (context) {
        return StatefulBuilder(builder: (context, dialogState) {
          return AlertDialog(
            title: const Text('新しい教科を追加'),
            content: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: '教科を入力', errorText: _errorMessage,
              ),
              onChanged: (value) {
                dialogState(() {
                  _errorMessage = null;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  if (text.isNotEmpty) {
                    if (!subjectData.containsKey(text)) {
                      setState(() {subjectData[text] = [];});
                      saveSubjectData();
                      Navigator.pop(context);
                    } else {
                      dialogState(() {
                        _errorMessage = 'その教科はすでに追加済みです';
                      });
                    }
                  } else {
                    dialogState(() {
                      _errorMessage = '教科を入力してください';
                    });
                  }
                },
                child: const Text('追加')
              ),
            ],
          );
        });
      }
    );
  }

  void _addMaterialDialog () {
    final TextEditingController textController = TextEditingController();
    String? _errorMessage;
    subject = true;

    showDialog(
      context: context, builder: (context) {
        return StatefulBuilder(builder: (context, dialogState) {
          if (subject) {
            return AlertDialog(
              title: const Text('教材を追加'),
              content: DropdownButton<String>(
                value: _selectedSubject,
                isExpanded: true,
                items: [
                  ...subjectData.keys.map((String key) {
                    return DropdownMenuItem<String>(value: key, child: Text(key));
                  })
                ],
                onChanged: (String? newValue) {
                  dialogState(() {
                    _selectedSubject = newValue;
                  });
                }
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル')
                ),
                ElevatedButton(
                  onPressed: () {
                    dialogState(() {
                      subject = false;
                    });
                  },
                  child: const Text('次へ')
                ),
              ],
            );
          } else {
            return AlertDialog(
              title: const Text('教材を追加'),
              content: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: '教材を入力',
                  errorText: _errorMessage,
                ),
                onChanged: (value) {
                  _errorMessage = null;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogState(() {
                      subject = true;
                    });
                  },
                  child: const Text('戻る')
                ),
                ElevatedButton(
                  onPressed: () {
                    final materials = subjectData[_selectedSubject];
                    final text = textController.text.trim();
                    if (materials != null && text.isNotEmpty && !materials.contains(text)) {
                      setState(() {materials.add(text);});
                      saveSubjectData();
                      Navigator.pop(context);
                    } else if (text.isEmpty) {
                      dialogState(() {
                        _errorMessage = '教材が入力されていません';
                      });
                    } else if (materials != null && materials.contains(text)) {
                      dialogState(() {
                        _errorMessage = 'その教材は追加済みです';
                      });
                    }
                  },
                  child: const Text('追加')
                )
              ],
            );
          }
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('追加'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => _addSubjectDialog(),
              child: const Text('教科を追加'),
            ),
            const SizedBox(height: 25,),
            OutlinedButton(
              onPressed: () => _addMaterialDialog(),
              child: const Text('教材を追加')
            ),
          ],
        ),
      ),
    );
  }
}

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録'),
      ),
      body: Center(

      )
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  DateTime? _startTime;
  Duration _alreadyPassed = Duration.zero;
  Duration _currentTime = Duration.zero;
  bool running = false;

  String? _selectedSubject;
  String? _selectedMaterial;

  @override
  void initState() {
    super.initState();
    _selectedSubject = subjectData.keys.firstOrNull;
    _selectedMaterial = subjectData[_selectedSubject]?.firstOrNull;
  }

  void startTimer() {
    if (running) return;
    _startTime = DateTime.now();
    setState(() {
      running = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimer();
    });
  }
  void _updateTimer() {
    if (_startTime == null) return;
    final now = DateTime.now();
    final diff = now.difference(_startTime!);
    setState(() {
      _currentTime = _alreadyPassed + diff;
    });
  }
  void stopTimer() {
    if (!running) return;
    _timer?.cancel();
    if (_startTime != null) {
      final now = DateTime.now();
      final diff = now.difference(_startTime!);
      setState(() {
        _alreadyPassed += diff;
      });
    }
    setState(() {
      running = false;
    });
  }
  void resetTimer() {
    _timer?.cancel();
    setState(() {
      running = false;
      _currentTime = Duration.zero;
      _alreadyPassed = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('測定'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_currentTime),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => resetTimer(),
                  child: const Text('リセット'),
                ),
                const SizedBox(width: 100,),
                OutlinedButton(
                  onPressed: () => running? stopTimer(): startTimer(),
                  child: running? const Text('ストップ'): const Text('スタート'),
                ),
              ],
            ),
            const SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _selectedSubject,
                  items: [
                    ...subjectData.keys.map((String key) {
                      return DropdownMenuItem<String>(value: key, child: Text(key));
                    })
                  ],
                  onChanged: _currentTime != Duration.zero || running
                  ? null
                  : (newValue) {
                    setState(() {
                      _selectedSubject = newValue;
                      _selectedMaterial = subjectData[_selectedSubject]?.firstOrNull;
                    });
                  }
                ),
                const SizedBox(width: 25,),
                DropdownButton<String>(
                  value: _selectedMaterial,
                  items: [
                    ...(subjectData[_selectedSubject] ?? []).map((String material) {
                      return DropdownMenuItem<String>(value: material, child: Text(material));
                    })
                  ],
                  onChanged: _currentTime != Duration.zero || running
                  ? null
                  : (newValue) {
                    setState(() {
                      _selectedMaterial = newValue;
                    });
                  }
                ),
                const SizedBox(width: 25,),
                if (_currentTime != Duration.zero && !running)
                  OutlinedButton(
                    onPressed: () {
                      final newRecord = StudyRecord(
                        date: DateTime.now(),
                        subject: _selectedSubject ?? '未選択',
                        material: _selectedMaterial ?? '未選択',
                        durationMinutes: _currentTime.inMinutes,
                      );
                      setState(() {
                        studyTime.add(newRecord);
                      });
                      saveStudyTime();
                      resetTimer();
                    },
                    child: const Text('記録を追加'),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TypeScreen extends StatefulWidget {
  const TypeScreen({super.key});

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  String? _selectedSubject;
  String? _selectedMaterial;
  final TextEditingController _time = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSubject = subjectData.keys.firstOrNull;
    _selectedMaterial = subjectData[_selectedSubject]?.firstOrNull;
  }

  @override
  void dispose() {
    super.dispose();
    _time.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('入力'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                DropdownButton<String>(
                  value: _selectedSubject,
                  items: [
                    ...subjectData.keys.map((String key) {
                      return DropdownMenuItem<String>(value: key, child: Text(key));
                    })
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSubject = newValue;
                      _selectedMaterial = subjectData[_selectedSubject]?.firstOrNull;
                    });
                  }
                ),
                const SizedBox(width: 25,),
                DropdownButton<String>(
                  value: _selectedMaterial,
                  items: [
                    ...(subjectData[_selectedSubject] ?? []).map((String material) {
                      return DropdownMenuItem<String>(value: material, child: Text(material));
                    })
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMaterial = newValue;
                    });
                  }
                ),
              ]
            ),
            const SizedBox(height: 25,),
            SizedBox(
              width: 200,
              child:TextField(
                controller: _time,
                keyboardType: TextInputType.number, 
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '勉強時間(分)を入力'
                ),
              ),
            ),
            const SizedBox(height: 25,),
            OutlinedButton(
              onPressed: () {
                final newRecord = StudyRecord(
                  date: DateTime.now(),
                  subject: _selectedSubject ?? '未選択',
                  material: _selectedMaterial ?? '未選択',
                  durationMinutes: int.parse(_time.text),
                );
                setState(() {
                  studyTime.add(newRecord);
                });
                saveStudyTime();
                Navigator.pop(context);
              },
              child: const Text('記録を追加'),
            )
          ],
        ),
      ),
    );
  }
}