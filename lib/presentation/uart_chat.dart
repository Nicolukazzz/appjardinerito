import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UartChat extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothCharacteristic? characteristic;

  const UartChat({required this.device, this.characteristic, Key? key})
    : super(key: key);

  @override
  _UartChatState createState() => _UartChatState();
}

class _UartChatState extends State<UartChat> {
  final TextEditingController _messageController = TextEditingController();
  List<String> receivedMessages = [];
  bool isSending = false;

  void _sendMessage() async {
    String message = _messageController.text;
    if (widget.characteristic != null && message.isNotEmpty) {
      setState(() {
        isSending = true;
        receivedMessages.add("Tú: $message");
      });
      await widget.characteristic!.write(message.codeUnits);
      _messageController.clear();
      setState(() => isSending = false);
    }
  }

  @override
  void dispose() {
    widget.device.disconnect(); // Desconectar automáticamente al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Conectado a ${widget.device.name}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: receivedMessages.length,
            itemBuilder: (context, index) {
              return Align(
                alignment:
                    receivedMessages[index].startsWith("Tú")
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color:
                        receivedMessages[index].startsWith("Tú")
                            ? Colors.blue[100]
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    receivedMessages[index],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: isSending ? null : _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
