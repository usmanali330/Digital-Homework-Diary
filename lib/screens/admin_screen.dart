import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../models/assignment.dart';
import '../models/subject.dart';
import '../database/database_helper.dart';
import '../core/theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _schoolNameController;
  late TextEditingController _addressController;
  late TextEditingController _welcomeController;
  late TextEditingController _footerController;
  late TextEditingController _teacherController;
  late TextEditingController _principalController;

  Map<String, TextEditingController> _assignmentControllers = {};
  List<Subject> _subjects = [];
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController(text: "CAMBRIDGE SYSTEM SCHOOL & COLLEGE");
    _addressController = TextEditingController(text: "Campus Address Here");
    _welcomeController = TextEditingController(text: "Assalam_O_Alaikum Dear Parent! We Hope You are all doing well.");
    _footerController = TextEditingController(text: "The education and character development of your children are very important to us. Please ensure they complete their tasks.");
    _teacherController = TextEditingController();
    _principalController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    _subjects = await DatabaseHelper.instance.getSubjects();
    
    for (var subject in _subjects) {
      _assignmentControllers[subject.name] = TextEditingController();
    }

    if (provider.currentDiary != null) {
      final diary = provider.currentDiary!;
      _schoolNameController.text = diary.schoolName;
      _addressController.text = diary.schoolAddress;
      _welcomeController.text = diary.welcomeMessage;
      _footerController.text = diary.footerMessage;
      _teacherController.text = diary.teacherName;
      _principalController.text = diary.principalName;

      for (var assignment in diary.assignments) {
        if (_assignmentControllers.containsKey(assignment.subjectName)) {
          _assignmentControllers[assignment.subjectName]!.text = assignment.taskDescription;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _welcomeController.dispose();
    _footerController.dispose();
    _teacherController.dispose();
    _principalController.dispose();
    for (var controller in _assignmentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<DiaryProvider>(context, listen: false);
    
    List<Assignment> assignments = [];
    bool hasAnyTask = false;

    for (var entry in _assignmentControllers.entries) {
      final description = entry.value.text.trim();
      if (description.isNotEmpty) {
        hasAnyTask = true;
      }
      assignments.add(Assignment(
        subjectName: entry.key,
        taskDescription: description.isEmpty ? "Nil" : description,
      ));
    }

    if (!hasAnyTask) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one assignment.')),
      );
      return;
    }

    final newDiary = DiaryEntry(
      id: provider.currentDiary?.id,
      date: provider.formattedDate,
      gradeId: provider.selectedGrade!.id!,
      schoolName: _schoolNameController.text,
      schoolAddress: _addressController.text,
      welcomeMessage: _welcomeController.text,
      footerMessage: _footerController.text,
      teacherName: _teacherController.text,
      principalName: _principalController.text,
    );

    try {
      await provider.saveDiary(newDiary, assignments);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin: \${provider.selectedGrade?.name} (\${provider.formattedDate})'),
      ),
      body: _subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('School Info'),
                        TextFormField(
                          controller: _schoolNameController,
                          decoration: const InputDecoration(labelText: 'School Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Address'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Messages'),
                        TextFormField(
                          controller: _welcomeController,
                          decoration: const InputDecoration(labelText: 'Welcome Message'),
                          maxLines: 2,
                          textDirection: TextDirection.rtl,
                        ),
                        TextFormField(
                          controller: _footerController,
                          decoration: const InputDecoration(labelText: 'Footer Message'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Assignments'),
                        ..._subjects.map((subject) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextFormField(
                              controller: _assignmentControllers[subject.name],
                              decoration: InputDecoration(
                                labelText: subject.name,
                                border: const OutlineInputBorder(),
                                prefixIcon: Icon(Icons.book, color: subject.color),
                                suffixIcon: TextButton(
                                  onPressed: () => _assignmentControllers[subject.name]!.text = 'Nil',
                                  child: const Text('Nil'),
                                ),
                              ),
                              maxLines: null,
                              textDirection: subject.name == 'Urdu' || subject.name == 'Nazra' 
                                  ? TextDirection.rtl 
                                  : TextDirection.ltr,
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Signatures'),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _teacherController,
                                decoration: const InputDecoration(labelText: 'Teacher Name'),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _principalController,
                                decoration: const InputDecoration(labelText: 'Principal Name'),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _saveDiary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Save Diary', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkBlue),
      ),
    );
  }
}
