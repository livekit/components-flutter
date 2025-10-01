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

class TextInput extends StatelessWidget {
  TextInput(
      {super.key,
      required this.onTextChanged,
      required this.hintText,
      String? text})
      : _textController = TextEditingController(text: text ?? '');

  final TextEditingController _textController;

  final void Function(String) onTextChanged;

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      minLines: 1,
      maxLines: 1,
      onChanged: onTextChanged,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintMaxLines: 1,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 0.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Colors.black26,
            width: 0.2,
          ),
        ),
      ),
    );
  }
}
