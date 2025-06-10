// Copyright 2024 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'package:chat_bubbles/chat_bubbles.dart';

import '../../../context/chat_context.dart';
import '../theme.dart';
import 'data_chip.dart';

class ChatWidget extends StatelessWidget {
  ChatWidget({
    super.key,
    required this.messages,
    required this.onSend,
    required this.onClose,
  });

  final List<ChatMessage> messages;
  final Function(String) onSend;
  final Function() onClose;
  final ScrollController _scrollController = ScrollController();

  List<Widget> _buildMessages(List<ChatMessage> messages) {
    List<Widget> msgWidgets = [];
    int lastTimestamp = 0;
    String lastPartcipantId = '';
    for (ChatMessage msg in messages) {
      if (DateTime.fromMillisecondsSinceEpoch(msg.timestamp)
                  .difference(DateTime.fromMillisecondsSinceEpoch(lastTimestamp))
                  .inMinutes >
              1 ||
          lastPartcipantId != msg.participant?.identity) {
        msgWidgets.add(CustomDateNameChip(
            name: msg.participant?.name ?? 'Unknown', date: DateTime.fromMillisecondsSinceEpoch(msg.timestamp)));
      }
      msgWidgets.add(BubbleNormal(
        text: msg.message,
        color: const Color(0xFFE8E8EE),
        tail: false,
        isSender: msg.sender,
      ));

      lastTimestamp = msg.timestamp;
      lastPartcipantId = msg.participant?.identity ?? '';
    }
    return msgWidgets;
  }

  void scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LKColors.lkDarkBlue,
      padding: const EdgeInsets.all(1.0),
      child: Column(
        children: [
          Container(
            height: 50.0,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Messages',
                      style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: _buildMessages(messages),
              ),
            ),
          ),
          Container(
            color: LKColors.lkDarkBlue,
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: MessageBar(
              messageBarColor: LKColors.lkDarkBlue,
              replyWidgetColor: LKColors.lkDarkBlue,
              onSend: (msg) {
                onSend(msg);
                scrollToBottom();
              },
              onTextChanged: (msg) {
                if (msg.isNotEmpty && msg.codeUnits.last == 10) {
                  onSend(msg.substring(0, msg.length - 1));
                  scrollToBottom();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
