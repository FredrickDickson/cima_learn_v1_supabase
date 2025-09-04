import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  final String initialContent;
  final Function(String) onContentChanged;

  const RichTextEditor({
    Key? key,
    this.initialContent = '',
    required this.onContentChanged,
  }) : super(key: key);

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Wrap(
            children: [
              _buildToolbarButton(
                Icons.format_bold,
                'Bold',
                _isBold,
                () => setState(() => _isBold = !_isBold),
              ),
              _buildToolbarButton(
                Icons.format_italic,
                'Italic',
                _isItalic,
                () => setState(() => _isItalic = !_isItalic),
              ),
              _buildToolbarButton(
                Icons.format_underlined,
                'Underline',
                _isUnderlined,
                () => setState(() => _isUnderlined = !_isUnderlined),
              ),
              const SizedBox(width: 8),
              _buildToolbarButton(
                Icons.format_list_bulleted,
                'Bullet List',
                false,
                () => _insertText('• '),
              ),
              _buildToolbarButton(
                Icons.format_list_numbered,
                'Numbered List',
                false,
                () => _insertText('1. '),
              ),
              const SizedBox(width: 8),
              _buildToolbarButton(
                Icons.link,
                'Insert Link',
                false,
                _insertLink,
              ),
              _buildToolbarButton(
                Icons.image,
                'Insert Image',
                false,
                _insertImage,
              ),
            ],
          ),
        ),
        
        // Text Editor
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Start typing your content...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                decoration: _isUnderlined ? TextDecoration.underline : TextDecoration.none,
              ),
              onChanged: widget.onContentChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, bool isActive, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: isActive ? const Color(0xFFB71C1C).withOpacity(0.1) : null,
            foregroundColor: isActive ? const Color(0xFFB71C1C) : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _insertText(String text) {
    final currentText = _controller.text;
    final selection = _controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
    
    widget.onContentChanged(newText);
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (context) {
        String linkText = '';
        String linkUrl = '';
        
        return AlertDialog(
          title: const Text('Insert Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Link Text',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => linkText = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => linkUrl = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (linkText.isNotEmpty && linkUrl.isNotEmpty) {
                  _insertText('[$linkText]($linkUrl)');
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Insert'),
            ),
          ],
        );
      },
    );
  }

  void _insertImage() {
    showDialog(
      context: context,
      builder: (context) {
        String imageUrl = '';
        String altText = '';
        
        return AlertDialog(
          title: const Text('Insert Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => imageUrl = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Alt Text (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => altText = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (imageUrl.isNotEmpty) {
                  final imageMarkdown = altText.isNotEmpty
                      ? '![${altText}](${imageUrl})'
                      : '![Image](${imageUrl})';
                  _insertText(imageMarkdown);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Insert'),
            ),
          ],
        );
      },
    );
  }
}