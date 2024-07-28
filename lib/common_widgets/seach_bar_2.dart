import 'package:flutter/material.dart';

import '../model/module.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSuggestionSelected;
  final List<Module> suggestions;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSuggestionSelected,
    required this.suggestions,
  });

  @override
  CustomSearchBarState createState() => CustomSearchBarState();
}

class CustomSearchBarState extends State<CustomSearchBar> {
  bool showSuggestions = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        showSuggestions = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onTap: () {
            setState(() {
              showSuggestions = true;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a valid module code';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter module code',
            prefixIcon: const Icon(Icons.code),
            focusColor: Colors.brown[300],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (showSuggestions && widget.suggestions.isNotEmpty)
          Container(
            height: 200,
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:
                  widget.suggestions.length > 5 ? 5 : widget.suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.suggestions[index].code),
                  onTap: () {
                    widget.controller.text = widget.suggestions[index].code;
                    widget.onChanged(widget.controller.text);
                    widget.onSuggestionSelected(widget.controller.text);
                    setState(() {
                      showSuggestions = false;
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
