import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/const_color.dart';
import '../constants/constant.dart';
import '../units/build_input_decorations.dart';
class chat_page extends StatefulWidget {
  const chat_page({super.key});

  @override
  State<chat_page> createState() => _chat_pageState();
}

class _chat_pageState extends State<chat_page> {
  TextEditingController controller= TextEditingController();
  final _openAI = OpenAI.instance.build(token: OPENAI_API_KEY,baseOption: HttpSetup(receiveTimeout:Duration(seconds: 5)),enableLog:true);
  final ChatUser _currentUser = ChatUser(id: '1',firstName: 'Mira',lastName: 'Jamous');
  final ChatUser _gptChatUser = ChatUser(id: '2',firstName: 'Chat',lastName: 'GPT');
  List <ChatMessage> _messages=<ChatMessage>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kRed,
        title:const Text('SpectrumBot',style: TextStyle(color: Colors.white)),
      ),
    body: DashChat(
                  currentUser:_currentUser,
                  messageOptions: MessageOptions
                                  (currentUserContainerColor: kBlue,
                                   currentUserTextColor: Colors.black,
                                   containerColor: kDarkBlue,
                                   textColor: kPrimary,
                                   timeFormat: DateFormat.jm(),
                    
                                   ),
                  onSend: (ChatMessage m){
                          getChatResponse(m);
                          },
                  messages:_messages,
                  inputOptions: InputOptions(
                              inputDecoration: buildInputDecoration(null, null, "Write Your Message Here", false, false),
                              inputTextStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: kDarkerColor,
                                      ),
                              ),
                  )
    );
  }
  Future<void> getChatResponse(ChatMessage m)async{
    setState((){
      _messages.insert(0,m);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m){
      if(m.user == _currentUser){
        return Messages(role: Role.user,content: m.text);
      }
      else {
        return Messages(role: Role.assistant,content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(model: GptTurbo0301ChatModel(),messages: _messagesHistory, maxToken: 200);
    final response = await _openAI.onChatCompletion(request: request);
    for(var element in response!.choices){
      if(element.message != null){
        setState((){
          _messages.insert(0,ChatMessage(user: _gptChatUser, createdAt: DateTime.now(),text: element.message!.content));
        });
      }
    }
  }
}
