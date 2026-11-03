import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/diary_entry.dart';
import '../models/subject.dart';
import '../models/grade.dart';

class PdfService {
  static Future<void> generateAndHandleDiaryPdf(
    DiaryEntry diary,
    List<Grade> allGrades, {
    required bool shouldShare,
    required bool shouldPrint,
  }) async {
    final pdf = pw.Document();

    // Safe font loading
    pw.Font? urduFont;
    pw.Font? englishFont;

    try {
      final fontData = await rootBundle.load("assets/fonts/NotoNastaliqUrdu-Regular.ttf");
      urduFont = pw.Font.ttf(fontData);
    } catch (_) {
      urduFont = pw.Font.helvetica(); // Fallback
    }

    try {
      final poppinsData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      englishFont = pw.Font.ttf(poppinsData);
    } catch (_) {
      englishFont = pw.Font.helveticaBold(); // Fallback
    }

    final gradeName = allGrades.firstWhere((g) => g.id == diary.gradeId, 
        orElse: () => Grade(id: 0, name: 'Unknown')).name;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: englishFont,
          bold: englishFont,
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                children: [
                  pw.Text(diary.schoolName,
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text(diary.schoolAddress, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.SizedBox(height: 10),
                  pw.Text("DAILY HOMEWORK DIARY",
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Grade: $gradeName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("Date: ${diary.date}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // Welcome Message (Urdu Support)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              width: double.infinity,
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              child: pw.Text(
                diary.welcomeMessage,
                style: pw.TextStyle(font: urduFont, fontSize: 13),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 20),

            // Homework Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Subject", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Homework Details", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...diary.assignments.map((a) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(a.subjectName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        a.taskDescription,
                        style: pw.TextStyle(font: urduFont, fontSize: 12),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ),
                  ],
                )),
              ],
            ),

            pw.SizedBox(height: 30),
            pw.Text(diary.footerMessage, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.Spacer(),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSigColumn("Teacher: ${diary.teacherName}", "Class Teacher"),
                _buildSigColumn("Principal: ${diary.principalName}", "School Principal"),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Diary_${diary.date}_$gradeName.pdf");
    await file.writeAsBytes(await pdf.save());

    if (shouldPrint) {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } else if (shouldShare) {
      await Share.shareXFiles([XFile(file.path)], text: 'Homework Diary for ${diary.date}');
    }
  }

  static pw.Widget _buildSigColumn(String name, String label) {
    return pw.Column(
      children: [
        pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Container(width: 120, height: 1, color: PdfColors.black, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
