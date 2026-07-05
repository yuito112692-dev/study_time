import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, List<String>> subjectData = {
  '数学': ['青チャート', 'フォーカス', '実力強化', '4STEP', '塾', 'その他'],
  '英語': ['ジーニアス', 'カッティングエッジ', 'アースライズ', '塾', 'その他'],
  '国語': ['現代文', '古典', 'その他'],
  '物理': ['リード', '塾', 'その他'],
  '生物': ['リード', 'その他'],
  '地理': ['ワーク', 'その他'],
  '歴史': ['ワーク', 'その他'],
};

class StudyRecord {
    final DateTime date;
    final String subject;
    final String material;
    final int durationMinutes;

    StudyRecord({
        required this.date,
        required this.subject,
        required this.material,
        required this.durationMinutes,
    });

    Map<String, dynamic> toMap() {
      return {
        'date': date.toIso8601String(),
        'subject': subject,
        'material': material,
        'durationMinutes': durationMinutes,
      };
    }

    factory StudyRecord.fromMap(Map<String, dynamic> map) {
      return StudyRecord(
        date: map['date'], subject: map['subject'], material: map['material'],
        durationMinutes: map['durationMinutes'],
      );
    }
}

List<StudyRecord> studyTime = [];

Future<void> saveSubjectData() async {
  final prefs = await SharedPreferences.getInstance();
  String jsonStr = jsonEncode(subjectData);
  await prefs.setString('save_subject_data', jsonStr);
}
Future<void> saveStudyTime() async {
  final prefs = await SharedPreferences.getInstance();
  List<Map<String, dynamic>> mapList = studyTime.map((e) => e.toMap()).toList();
  String jsonStr = jsonEncode(mapList);
  await prefs.setString('save_study_time', jsonStr);
}
Future<void> loadAllData() async {
  final prefs = await SharedPreferences.getInstance();

  String? subjectJson = prefs.getString('save_subject_data');
  if (subjectJson != null) {
    Map<String, dynamic> decoded = jsonDecode(subjectJson);
    subjectData = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  String? timeJson = prefs.getString('save_study_time');
  if (timeJson != null) {
    List<dynamic> decodedList = jsonDecode(timeJson);
    studyTime = decodedList.map((e) => StudyRecord.fromMap(e)).toList();
  }
}