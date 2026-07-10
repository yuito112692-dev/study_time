import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:study_time/time.dart';
import 'dart:async';

Color getSubjectColor(String subjectName) {
  // 文字列から固有の数字（ハッシュコード）を計算する
  int hash = subjectName.hashCode;
  
  // 数字をもとに、RGB（赤・緑・青）の値を0〜255の間で計算する
  int r = (hash & 0xFF0000) >> 16;
  int g = (hash & 0x00FF00) >> 8;
  int b = (hash & 0x0000FF);
  
  // あまり暗い色や薄すぎる色にならないように、少し明るさを調整してカラーを返す
  return Color.fromARGB(255, (r % 150) + 80, (g % 150) + 80, (b % 150) + 80);
}

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
  int form = 1;
  final now = DateTime.now();
  Map<String, List<StudyRecord>> groupedRecords = {};
  List<BarChartGroupData> barGroups = [];

  @override
  Widget build(BuildContext context) {
    if (form == 1) {
      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final dateStr = "${targetDate.month}/${targetDate.day}";
        final dayRecords = studyTime.where((r) =>
          r.date.year == targetDate.year
          && r.date.month == targetDate.month
          && r.date.day == targetDate.day
        ).toList();

        double totalMinutes = 0;
        List<BarChartRodStackItem> stackItems = [];

        for (var r in dayRecords) {
          final double duration = r.durationMinutes.toDouble();
          stackItems.add(BarChartRodStackItem(
            totalMinutes, totalMinutes + duration, getSubjectColor(r.material)
          ));
          totalMinutes += duration;
        }
        barGroups.add(
          BarChartGroupData(
            x: 6 - i,
            barRods: [
              BarChartRodData(
                toY: totalMinutes,
                width: 16,
                borderRadius: BorderRadius.circular(4),
                rodStackItems: stackItems,
                color: Colors.grey.shade300,
              )
            ]
          )
        );
      }
    } else if (form == 2) {
      for (int i = 4; i >= 0; i--) {
        final targetWeekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
        final targetWeekEnd = targetWeekStart.add(const Duration(days: 6));
    
        // X軸のラベル用（例: "10/12~"）
        final weekLabel = "${targetWeekStart.month}/${targetWeekStart.day}~";

        // その週の期間内にあるレコードを抽出
        final weekRecords = studyTime.where((r) {
          final normalizedDate = DateTime(r.date.year, r.date.month, r.date.day);
          final start = DateTime(targetWeekStart.year, targetWeekStart.month, targetWeekStart.day);
          final end = DateTime(targetWeekEnd.year, targetWeekEnd.month, targetWeekEnd.day);
          return (normalizedDate.isAfter(start) || normalizedDate.isAtSameMomentAs(start)) &&
                (normalizedDate.isBefore(end) || normalizedDate.isAtSameMomentAs(end));
        }).toList();

        // 教科ごとに今週の合計時間を集計して積み上げグラフを作る
        Map<String, double> subjectMinutesMap = {};
        for (var r in weekRecords) {
          subjectMinutesMap[r.subject] = (subjectMinutesMap[r.subject] ?? 0) + r.durationMinutes;
        }

        double totalMinutes = 0;
        List<BarChartRodStackItem> stackItems = [];
        subjectMinutesMap.forEach((subject, minutes) {
          stackItems.add(BarChartRodStackItem(
            totalMinutes,
            totalMinutes + minutes,
            getSubjectColor(subject),
          ));
          totalMinutes += minutes;
        });

        barGroups.add(
          BarChartGroupData(
            x: 4 - i,
            barRods: [
              BarChartRodData(
                toY: totalMinutes,
                width: 24, // 週・月は少し太めにする
                borderRadius: BorderRadius.circular(4),
                rodStackItems: stackItems,
                color: Colors.grey.shade300,
              )
            ],
          ),
        );
      }
    } else if (form == 3) {
      // --- 【月ごと表示】 直近6ヶ月のデータを集計 ---
      for (int i = 5; i >= 0; i--) {
        // 過去の月を計算
        int targetMonth = now.month - i;
        int targetYear = now.year;
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }

        // その月のレコードを抽出
        final monthRecords = studyTime.where((r) =>
            r.date.year == targetYear && r.date.month == targetMonth).toList();

        // 教科ごとに今月の合計時間を集計
        Map<String, double> subjectMinutesMap = {};
        for (var r in monthRecords) {
          subjectMinutesMap[r.subject] = (subjectMinutesMap[r.subject] ?? 0) + r.durationMinutes;
        }

        double totalMinutes = 0;
        List<BarChartRodStackItem> stackItems = [];
        subjectMinutesMap.forEach((subject, minutes) {
          stackItems.add(BarChartRodStackItem(
            totalMinutes,
            totalMinutes + minutes,
            getSubjectColor(subject),
          ));
          totalMinutes += minutes;
        });

        barGroups.add(
          BarChartGroupData(
            x: 5 - i,
            barRods: [
              BarChartRodData(
                toY: totalMinutes,
                width: 32, // 月はさらに太め
                borderRadius: BorderRadius.circular(4),
                rodStackItems: stackItems,
                color: Colors.grey.shade300,
              )
            ],
          ),
        );
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: form == 3 ? Colors.grey[350] : Colors.white
                  ),
                  onPressed: () {setState(() {
                      form = 3;
                    });
                  },
                  child: const Text('月')
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: form == 2 ? Colors.grey[350] : Colors.white
                  ),
                  onPressed: () {setState(() {
                      form = 2;
                    });
                  },
                  child: const Text('週')
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: form == 1 ? Colors.grey[350] : Colors.white
                  ),
                  onPressed: () {setState(() {
                      form = 1;
                    });
                  },
                  child: const Text('日')
                ),
              ],
            ),
            const SizedBox(height: 30,),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      tooltipBorder: const BorderSide(color: Colors.white, width: 1),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String dateKey = groupedRecords.keys.toList()[group.x];
                        List<StudyRecord> dayRecords = groupedRecords[dateKey] ?? [];
                        double touchY = rod.toY;

                        StringBuffer textBuffer = StringBuffer();
                        textBuffer.writeln(dateKey);
                        textBuffer.writeln('—————————————');
                        for (var record in dayRecords) {
                          textBuffer.writeln('${record.subject}(${record.material}): ${record.durationMinutes}分');
                        }
                        return BarTooltipItem(
                          textBuffer.toString(),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          )
                        );
                      },
                    )
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: groupedRecords.entries.map((entry) {
                    int index = groupedRecords.keys.toList().indexOf(entry.key);
                    List<StudyRecord> dayRecords = entry.value;
                    Map<String, int> materialTotalMinutes = {};
                    for (var record in dayRecords) {
                      String key = record.material;
                      if (materialTotalMinutes.containsKey(key)) {
                        materialTotalMinutes[key] = materialTotalMinutes[key]! + record.durationMinutes;
                      } else {
                        materialTotalMinutes[key] = record.durationMinutes;
                      }
                    }

                    double totalHeight = 0;
                    List<BarChartRodStackItem> stackItems = [];

                    materialTotalMinutes.forEach((materialName, minutes) {
                      double duration = minutes.toDouble();
                      stackItems.add(
                        BarChartRodStackItem(
                          totalHeight, 
                          totalHeight + duration, 
                          getSubjectColor(materialName)
                        )
                      );
                      totalHeight += duration;
                    });
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: totalHeight,
                          width: 25,
                          rodStackItems: stackItems,
                        )
                      ]
                    );
                  }).toList()
                )
              ),
            )
          ]
        )
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