import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaguard1/core/theme/app_color.dart';
import 'package:diaguard1/features/patient/chatbot/chatbot_patient.dart';

class InsulinInfoPage extends StatefulWidget {
  @override
  _InsulinInfoPageState createState() => _InsulinInfoPageState();
}

class _InsulinInfoPageState extends State<InsulinInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _carbRatioController = TextEditingController();
  final _correctionFactorController = TextEditingController();
  final _targetSugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfDataExists();
  }

  Future<void> _checkIfDataExists() async {
    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.containsKey('carbRatio') &&
        prefs.containsKey('correctionFactor') &&
        prefs.containsKey('targetSugar');
    if (hasData) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InsulinCalcPage()),
      );
    }
  }

  Future<void> _saveDataAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('carbRatio', double.parse(_carbRatioController.text));
    await prefs.setDouble('correctionFactor', double.parse(_correctionFactorController.text));
    await prefs.setDouble('targetSugar', double.parse(_targetSugarController.text));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InsulinCalcPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(isArabic ? 'معلومات الإنسولين' : 'Insulin Info'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _carbRatioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isArabic ? 'معامل الكربوهيدرات' : 'Carb Ratio (g/U)',
                ),
              ),
              TextFormField(
                controller: _correctionFactorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isArabic ? 'معامل التصحيح' : 'Correction Factor (mg/dL per U)',
                ),
              ),
              TextFormField(
                controller: _targetSugarController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isArabic ? 'السكر الطبيعي' : 'Target Blood Sugar (mg/dL)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveDataAndNavigate();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.teal[700],
                ),
                child: Text(
                  isArabic ? 'احسب الجرعة' : 'Calculate Dose',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2),
    );
  }
}

class InsulinCalcPage extends StatefulWidget {
  @override
  _InsulinCalcPageState createState() => _InsulinCalcPageState();
}

class _InsulinCalcPageState extends State<InsulinCalcPage> {
  final _carbAmountController = TextEditingController();
  final _currentSugarController = TextEditingController();
  double? _dose;
  double? carbRatio;
  double? correctionFactor;
  double? targetSugar;

  @override
  void initState() {
    super.initState();
    _loadStoredValues();
  }

  Future<void> _loadStoredValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      carbRatio = prefs.getDouble('carbRatio') ?? 10.0;
      correctionFactor = prefs.getDouble('correctionFactor') ?? 50.0;
      targetSugar = prefs.getDouble('targetSugar') ?? 120.0;
    });
  }

  void _calculateDose() {
    double carb = double.tryParse(_carbAmountController.text) ?? 0;
    double sugar = double.tryParse(_currentSugarController.text) ?? 0;

    double mealInsulin = carb / (carbRatio ?? 1);
    double correctionInsulin = (sugar - (targetSugar ?? 0)) / (correctionFactor ?? 1);
    double totalDose = mealInsulin + correctionInsulin;

    setState(() {
      _dose = totalDose;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.teal[700],
        title: Text(isArabic ? 'حساب الجرعة' : 'Insulin Calculation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _carbAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isArabic ? 'كمية الكربوهيدرات (جم)' : 'Carbohydrates (g)',
              ),
            ),
            TextField(
              controller: _currentSugarController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isArabic ? 'السكر الحالي (ملجم/دل)' : 'Current Blood Sugar (mg/dL)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateDose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
              ),
              child: Text(
                isArabic ? 'احسب' : 'Calculate',
                style: TextStyle(color: Colors.white),
              ),
            ),
            if (_dose != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  isArabic
                      ? 'الجرعة الموصى بها: ${_dose!.toStringAsFixed(1)} وحدة'
                      : 'Recommended Dose: ${_dose!.toStringAsFixed(1)} units',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BottomNavigationBar(
      currentIndex: currentIndex.clamp(0, 3),
      selectedItemColor: AppColors.background,
      unselectedItemColor: Colors.teal[700],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/chart_patient');
            break;
          case 2:
            Navigator.pushNamed(context, '/insulin_calc');
            break;
          case 3:
            Navigator.pushNamed(context, '/chatbot_patient');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: isArabic ? 'الرئيسية' : 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: isArabic ? 'مخطط جلوكوز' : 'Graph',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: isArabic ? 'الإنسولين' : 'Insulin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: isArabic ? 'مساعد' : 'Chatbot',
        ),
      ],
    );
  }
}