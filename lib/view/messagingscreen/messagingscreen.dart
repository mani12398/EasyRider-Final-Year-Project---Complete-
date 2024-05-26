import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/customtext.dart';

void checkdocexistornot(String rideId) async {
  var collection = FirebaseFirestore.instance.collection('conversations');
  var doc = collection.doc(rideId);

  var docSnapshot = await doc.get();

  if (!docSnapshot.exists) {
    await doc.set({
      'driverMessages': [],
      'userMessages': [],
    });
  }
}

class ChatScreen extends StatefulWidget {
  final String title;
  final bool isDriver;
  final String rideId;

  const ChatScreen(
      {super.key,
      required this.title,
      required this.isDriver,
      required this.rideId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    checkdocexistornot(widget.rideId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: widget.title, backgroundColor: Colors.transparent),
      body: ChatBody(isDriver: widget.isDriver, rideId: widget.rideId),
    );
  }
}

class ChatBody extends StatelessWidget {
  final bool isDriver;
  final String rideId;

  const ChatBody({super.key, required this.isDriver, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('conversations')
                .doc(rideId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CustomText(
                  title: 'No messages here to display',
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  color: Appcolors.contentTertiary,
                  fontWeight: FontWeight.w600,
                ));
              }
              var userMessages =
                  snapshot.data!.get('userMessages') as List<dynamic>;
              var driverMessages =
                  snapshot.data!.get('driverMessages') as List<dynamic>;

              List<Map<String, dynamic>> allMessages = [];

              for (var msg in userMessages) {
                allMessages.add({...msg, 'isMe': !isDriver});
              }

              for (var msg in driverMessages) {
                allMessages.add({...msg, 'isMe': isDriver});
              }

              allMessages.sort((a, b) =>
                  (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: allMessages.length,
                itemBuilder: (context, index) {
                  var msg = allMessages[index];
                  return MessageBubble(
                    message: msg['message'],
                    time: formatTimestamp(msg['time']),
                    isMe: msg['isMe'],
                  );
                },
              );
            },
          ),
        ),
        ChatInputField(isDriver: isDriver, rideId: rideId),
      ],
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    return '${date.hour}:${date.minute} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class ChatInputField extends StatelessWidget {
  final bool isDriver;
  final String rideId;

  ChatInputField({Key? key, required this.isDriver, required this.rideId})
      : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Appcolors.primaryColor),
            onPressed: () {
              // Plus icon functionality
            },
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Positioned(
                  right: 8.0,
                  child: IconButton(
                    icon: const Icon(Icons.emoji_emotions,
                        color: Appcolors.primaryColor),
                    onPressed: () {
                      // Emoji button functionality
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Transform.rotate(
            angle: -0.9,
            child: IconButton(
              icon: const Icon(Icons.send, color: Appcolors.primaryColor),
              onPressed: _sendMessage,
            ),
          )
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    var collection = FirebaseFirestore.instance.collection('conversations');
    var doc = collection.doc(rideId);

    var message = _controller.text.trim();
    var timestamp = Timestamp.now();

    if (isDriver) {
      await doc.update({
        'driverMessages': FieldValue.arrayUnion([
          {'message': message, 'time': timestamp}
        ])
      });
    } else {
      await doc.update({
        'userMessages': FieldValue.arrayUnion([
          {'message': message, 'time': timestamp}
        ])
      });
    }

    _controller.clear();
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const MessageBubble(
      {Key? key, required this.message, required this.time, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Appcolors.primaryColor, width: 2),
            ),
            child: const CircleAvatar(
              backgroundColor: Appcolors.primaryColor,
              foregroundColor: Colors.black,
              child: Icon(Icons.person),
            ),
          ),
        const SizedBox(width: 8.0),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isMe ? Appcolors.primary100 : Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
            border: isMe
                ? Border.all(color: Appcolors.primaryColor, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 4.0),
              Text(
                time,
                style: TextStyle(
                    fontSize: 12.0,
                    color: isMe ? Colors.black : Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        if (isMe)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Appcolors.primaryColor, width: 2),
            ),
            child: const CircleAvatar(
              backgroundColor: Appcolors.primaryColor,
              foregroundColor: Colors.black,
              child: Icon(Icons.person),
            ),
          ),
      ],
    );
  }
}
