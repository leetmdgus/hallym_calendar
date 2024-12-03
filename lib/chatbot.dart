import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'setting.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  late SharedPreferences prefs;
  List<String> chatbotHistory = [];

  getInitState() async {
    prefs = await SharedPreferences.getInstance();
    chatbotHistory = prefs.getStringList('$userEmail chatbotHistory') ?? [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getInitState();
  }

  Future<void> _sendMessage(String value) async {
    if (value.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      chatbotHistory.add(value);
      _textController.clear();
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() async {
        final prompt = value;
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        chatbotHistory.add(response.text as String);

        _focusNode.requestFocus();
        prefs.setStringList('$userEmail chatbotHistory', chatbotHistory);

        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: isSunnyMode ? Colors.white : Colors.black87,
          title: Text(
            '20245223 이승현',
            style: TextStyle(color: isSunnyMode ? Colors.black : Colors.grey),
          ),
        ),
        body: Container(
          color: isSunnyMode ? Colors.white : Colors.black87,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chatbotHistory.length,
                        itemBuilder: (context, index) {
                          final isUserMessage = index % 2 == 0;
                          return Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 300,
                              ),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? Colors.deepPurple
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chatbotHistory[index],
                                style: TextStyle(
                                    color: isUserMessage
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.top,
                    left: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isLoading) const LinearProgressIndicator(),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                  color:
                                      isSunnyMode ? Colors.black : Colors.grey),
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              controller: _textController,
                              focusNode: _focusNode,
                              onSubmitted: (value) {
                                if (!isLoading) {
                                  _sendMessage(value);
                                }
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '메시지를 입력하세요.',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (!isLoading) {
                                _sendMessage(_textController.text);
                              }
                            },
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
