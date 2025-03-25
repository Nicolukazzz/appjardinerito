import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appjardinerito/main.dart';

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
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = isDarkMode ? Colors.green[700] : Color(0xFF487363);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comunicación UART",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Conectado a ${widget.device.name}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: receivedMessages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = receivedMessages[index].startsWith("Tú");
                return Align(
                  alignment:
                      isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          isUserMessage
                              ? (isDarkMode ? Colors.green[800] : primaryColor)
                              : (isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200]),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isUserMessage ? 12 : 0),
                        topRight: Radius.circular(isUserMessage ? 0 : 12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      receivedMessages[index],
                      style: GoogleFonts.poppins(
                        color:
                            isUserMessage
                                ? Colors.white
                                : (isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      hintStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  color: primaryColor,
                  onPressed: isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
