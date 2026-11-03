import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import '../models/grade.dart';
import '../models/assignment.dart';

class DiaryProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  Grade? _selectedGrade;
  DiaryEntry? _currentDiary;
  List<Grade> _grades = [];
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get selectedDate => _selectedDate;
  Grade? get selectedGrade => _selectedGrade;
  DiaryEntry? get currentDiary => _currentDiary;
  List<Grade> get grades => _grades;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  DiaryProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _grades = await DatabaseHelper.instance.getGrades();
      if (_grades.isNotEmpty) {
        _selectedGrade = _grades.first;
      }
      await loadDiary();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadDiary();
  }

  void setSelectedGrade(Grade grade) {
    _selectedGrade = grade;
    loadDiary();
  }

  Future<void> loadDiary() async {
    if (_selectedGrade == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentDiary = await DatabaseHelper.instance.getDiaryByDateAndGrade(
        formattedDate,
        _selectedGrade!.id!,
      );
    } catch (e) {
      _errorMessage = "Failed to load diary: \$e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDiary(DiaryEntry diary, List<Assignment> assignments) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (diary.id == null) {
        await DatabaseHelper.instance.insertDiary(diary, assignments);
      } else {
        await DatabaseHelper.instance.updateDiary(diary, assignments);
      }
      await loadDiary();
    } catch (e) {
      _errorMessage = "Failed to save diary: \$e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDiary() async {
    if (_currentDiary?.id == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseHelper.instance.deleteDiary(_currentDiary!.id!);
      await loadDiary();
    } catch (e) {
      _errorMessage = "Failed to delete diary: \$e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
