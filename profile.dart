import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaguard1/core/service/auth.dart';
import 'package:diaguard1/core/service/question_service.dart';
import 'package:diaguard1/features/questionnaire/data/question_data.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final AuthService authService;

  const ProfileScreen({
    Key? key,
    required this.userName,
    required this.authService,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late QuestionService questionService;
  Map<int, String> answers = {};
  bool isLoading = true;

  final TextEditingController _lowController = TextEditingController();
  final TextEditingController _highController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionService = QuestionService(authService: widget.authService);
    _loadAnswers();
    _loadThresholds();
  }

  Future<void> _loadAnswers() async {
    setState(() => isLoading = true);
    try {
      final loadedAnswers = await questionService.getAnswers();
      setState(() => answers = loadedAnswers);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل البيانات: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    final low = prefs.getDouble('lowThreshold') ?? 70.0;
    final high = prefs.getDouble('highThreshold') ?? 180.0;
    _lowController.text = low.toString();
    _highController.text = high.toString();
  }

  Future<void> _saveThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    final low = double.tryParse(_lowController.text);
    final high = double.tryParse(_highController.text);
    if (low != null && high != null) {
      await prefs.setDouble('lowThreshold', low);
      await prefs.setDouble('highThreshold', high);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث رينج التنبيه بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('من فضلك أدخل قيم صحيحة')),
      );
    }
  }

  @override
  void dispose() {
    _lowController.dispose();
    _highController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadAnswers),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  'إجابات المستخدم:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                ...answers.entries.map((entry) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        entry.value,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                Divider(thickness: 2),
                const SizedBox(height: 16),
                Text(
                  'تعديل رينج التنبيه للسكر:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lowController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'أقل قيمة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _highController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'أعلى قيمة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveThresholds,
                  icon: Icon(Icons.save),
                  label: Text('حفظ الإعدادات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
    );
  }
}
