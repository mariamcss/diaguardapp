import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatbotPatientPage extends StatefulWidget {
  @override
  _ChatbotPatientPageState createState() => _ChatbotPatientPageState();
}

class _ChatbotPatientPageState extends State<ChatbotPatientPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final int _currentIndex = 3;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final welcomeText = isArabic
        ? " اسألني عن السكر أو الإنسولين أو التغذية 🌱"
        : " Ask me anything about glucose, insulin, or nutrition 🌱";
    final helloHero = isArabic ? "أهلاً بالبطل 👋" : "Hello Hero 👋";

    _addWelcomeMessage("$helloHero $welcomeText");
  });
}


  void _sendMessage() {
  if (_controller.text.trim().isEmpty) return;

  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  setState(() {
    _messages.add(Message(text: _controller.text.trim(), isUser: true));
  });

  _controller.clear();

  // Simulated bot response with typing effect
  String botReply = isArabic
      ? "مرحباً! أنا مساعدك الغذائي من Diaguard 🤖 كيف أقدر أساعدك؟"
      : "Hi, I'm your Diaguard Nutritional Assistant 🤖 How can I help you?";

  String currentText = "";
  int i = 0;

  Timer.periodic(Duration(milliseconds: 30), (Timer timer) {
    if (i < botReply.length) {
      currentText += botReply[i];
      if (_messages.isNotEmpty && !_messages.last.isUser) {
        setState(() {
          _messages[_messages.length - 1] =
              Message(text: currentText, isUser: false);
        });
      } else {
        setState(() {
          _messages.add(Message(text: currentText, isUser: false));
        });
      }
      i++;
    } else {
      timer.cancel();
    }
  });
}

  void _addWelcomeMessage(String botReply) {
    String currentText = "";

    int i = 0;
    Timer.periodic(Duration(milliseconds: 30), (Timer timer) {
      if (i < botReply.length) {
        currentText += botReply[i];
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          setState(() {
            _messages[_messages.length - 1] = Message(text: currentText, isUser: false);
          });
        } else {
          setState(() {
            _messages.add(Message(text: currentText, isUser: false));
          });
        }
        i++;
      } else {
        timer.cancel();
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

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
        // Already on chatbot page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مساعد التغذية' : 'Chatbot'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: 270),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.teal[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.text, style: TextStyle(fontSize: 15)),
                        SizedBox(height: 5),
                        Text(
                          DateFormat('yyyy/MM/dd HH:mm').format(msg.timestamp),
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: isArabic ? 'اكتب الرسالة' : 'Write message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal[700]),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
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
            label: isArabic ? 'الإنسولين' : 'Dose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: isArabic ? 'مساعد' : 'Chatbot',
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, DateTime? timestamp})
      : this.timestamp = timestamp ?? DateTime.now();
}
