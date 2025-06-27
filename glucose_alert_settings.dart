
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

class GlucoseAlertSettings extends StatefulWidget {
  const GlucoseAlertSettings({Key? key}) : super(key: key);

  @override
  _GlucoseAlertSettingsState createState() => _GlucoseAlertSettingsState();
}

class _GlucoseAlertSettingsState extends State<GlucoseAlertSettings> {
  final _lowController = TextEditingController();
  final _highController = TextEditingController();
  double? _low;
  double? _high;

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _low = prefs.getDouble('lowThreshold') ?? 70.0;
      _high = prefs.getDouble('highThreshold') ?? 180.0;
      _lowController.text = _low.toString();
      _highController.text = _high.toString();
    });
  }

  Future<void> _saveThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    final low = double.tryParse(_lowController.text);
    final high = double.tryParse(_highController.text);
    if (low != null && high != null) {
      await prefs.setDouble('lowThreshold', low);
      await prefs.setDouble('highThreshold', high);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث القيم بنجاح!')),
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
        title: Text('تحديد رينج السكر للتنبيه'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _lowController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'أقل قيمة (Low Threshold)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _highController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'أعلى قيمة (High Threshold)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveThresholds,
              child: Text('حفظ الإعدادات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 48),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ✅ دالة يتم استدعاؤها بعد قراءة سكر (صائم أو غير صائم)
Future<void> checkGlucoseAndTriggerAlert(BuildContext context, double sugar) async {
  final prefs = await SharedPreferences.getInstance();
  final low = prefs.getDouble('lowThreshold') ?? 70.0;
  final high = prefs.getDouble('highThreshold') ?? 180.0;

  if (sugar < low || sugar > high) {
    final emergencyName = prefs.getString('emergencyName') ?? 'شخص للطوارئ';
    final emergencyPhone = prefs.getString('emergencyPhone') ?? '0000000000';

    // ✅ صوت تنبيه
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/alarm.mp3'));

    // ✅ إظهار تنبيه حوار
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('🚨 تنبيه سكر'),
        content: Text(
          sugar < low
              ? 'انخفاض في مستوى السكر!\nيرجى التواصل مع $emergencyName على $emergencyPhone'
              : 'ارتفاع في مستوى السكر!\nيرجى التواصل مع $emergencyName على $emergencyPhone',
        ),
        actions: [
          TextButton(
            child: Text('اتصال'),
            onPressed: () async {
              final uri = Uri.parse('tel:$emergencyPhone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          TextButton(
            child: Text('إغلاق'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
