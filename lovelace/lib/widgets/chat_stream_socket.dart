import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:lovelace/resources/storage_methods.dart';
import 'package:lovelace/utils/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// STEP1:  Stream setup
class ChatStreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

ChatStreamSocket streamSocket = ChatStreamSocket();

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream
void connectAndListen(
    String senderName, String receiverName, String keyName) async {
  dynamic cookie = await StorageMethods().read("cookie");
  StreamingSharedPreferences preferences =
      await StreamingSharedPreferences.instance;
  Preference<String> content =
      preferences.getString(keyName, defaultValue: "[]");
  socket_io.Socket socket = socket_io.io(
      Uri.http(baseUrl, '/chat').toString(),
      socket_io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie
      }).build());

  socket.onConnect((_) {
    socket.emit('join',
        {"user1": senderName, "user2": receiverName, "pubKey": "HELLOWORLD"});
  });

  socket.on('sent', (data) {
    Map<String, dynamic> chatMessageMap = data['message'];
    dynamic oldContent = json.decode(content.getValue());
    Map<String, dynamic> lastOldContent = oldContent[oldContent.length - 1];
    String chatMessageMapString = json.encode(chatMessageMap);
    String lastOldContentString = json.encode(lastOldContent);
    if (chatMessageMapString != lastOldContentString) {
      oldContent.add(chatMessageMap);
      String newContent = json.encode(oldContent);
      content.setValue(newContent);
      print("new message received");
    }
  });

  socket.onDisconnect((_) {
    socket.emit('leave', {"user1": senderName, "user2": receiverName});
  });
}

void disconnect(String senderName, String receiverName, String keyName) async {
  dynamic cookie = await StorageMethods().read("cookie");
  // String baseUrl = checkDevice();
  String baseUrl = "ec2-13-229-224-40.ap-southeast-1.compute.amazonaws.com";

  socket_io.Socket socket = socket_io.io(
      Uri.http(baseUrl, '/chat').toString(),
      socket_io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie
      }).build());

  socket.emit('leave', {"user1": senderName, "user2": receiverName});
  socket.disconnect();
}

void sendingMessage(
    // dynamic chatMessageMap,
    Encrypted encryptedMessage,
    String senderEmail,
    String receiverEmail,
    dynamic senderPubKey,
    dynamic receiverPubKey) async {
  dynamic cookie = await StorageMethods().read("cookie");
  // String baseUrl = checkDevice();
  String baseUrl = "ec2-13-229-224-40.ap-southeast-1.compute.amazonaws.com";

  socket_io.Socket socket = socket_io.io(
      Uri.http(baseUrl, '/chat').toString(),
      socket_io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie
      }).build());

  socket.emit('sent', {
    "message": encryptedMessage,
    "user1": senderEmail,
    "user2": receiverEmail,
    "pubKey1": senderPubKey,
    "pubKey2": receiverPubKey,
  });
  // print(chatMessageMap);
}

//Step3: Build widgets with streambuilder

// class ChatStreamSocketBuild extends StatelessWidget {
//   const ChatStreamSocketBuild({required Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: streamSocket.getResponse,
//       builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//         print(snapshot.data!);
//         return Text(snapshot.data!);
//       },
//     );
//   }
// }
