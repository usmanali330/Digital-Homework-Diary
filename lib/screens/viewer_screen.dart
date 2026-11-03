import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../core/theme.dart';
import '../widgets/greeting_banner.dart';
import '../widgets/assignment_row.dart';
import '../widgets/diary_footer.dart';
import '../services/pdf_service.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';
import 'admin_screen.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  List<Subject> _allSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await DatabaseHelper.instance.getSubjects();
    setState(() {
      _allSubjects = subjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final diary = provider.currentDiary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Work Diary'),
        actions: diary != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, provider),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePdfAction(value, diary, provider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'print', child: Text('Print')),
                    const PopupMenuItem(value: 'share', child: Text('Share PDF')),
                    const PopupMenuItem(value: 'export', child: Text('Export PDF')),
                  ],
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          _buildFilterBar(context, provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : diary == null
                    ? _buildEmptyState(context)
                    : _buildDiaryContent(diary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, DiaryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: provider.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) provider.setSelectedDate(date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                child: Text(DateFormat('yyyy-MM-dd').format(provider.selectedDate)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: provider.selectedGrade?.id,
              decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder()),
              items: provider.grades.map((g) {
                return DropdownMenuItem(value: g.id, child: Text(g.name));
              }).toList(),
              onChanged: (val) {
                final grade = provider.grades.firstWhere((g) => g.id == val);
                provider.setSelectedGrade(grade);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryContent(diary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                diary.schoolName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkBlue),
              ),
              Text(diary.schoolAddress, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text(
                'Home Work Diary For Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 32),
              GreetingBanner(message: diary.welcomeMessage),
              const SizedBox(height: 16),
              ...diary.assignments.map((a) {
                final sub = _allSubjects.firstWhere((s) => s.name == a.subjectName,
                    orElse: () => Subject(name: a.subjectName, colorCode: '1E56A0'));
                return AssignmentRow(assignment: a, subject: sub);
              }).toList(),
              DiaryFooter(
                footerMessage: diary.footerMessage,
                teacherName: diary.teacherName,
                principalName: diary.principalName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No diary found for this date and grade.'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Diary'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, DiaryProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary?'),
        content: const Text('Are you sure you want to delete this diary entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) provider.deleteDiary();
  }

  void _handlePdfAction(String action, DiaryEntry diary, DiaryProvider provider) {
    PdfService.generateAndHandleDiaryPdf(
      diary,
      provider.grades,
      shouldPrint: action == 'print',
      shouldShare: action == 'share',
    );
  }
}
