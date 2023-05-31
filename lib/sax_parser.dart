import 'dart:convert';

import 'package:xml_parser/xml_element.dart';

import 'content_handler.dart';

class SaxParser {
  bool isWellFormed(String xmlString) {
    try {
      final contentHandler = MyContentHandler();
      parse(xmlString, contentHandler);
      return true;
    } catch (e) {
      return false;
    }
  }

  void parse(String xmlString, XmlContentHandler contentHandler) {
    final lines = LineSplitter().convert(xmlString);
    final elementStack = <XmlElement>[];

    for (var line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('<!--')) {
        contentHandler
            .comment(trimmedLine.substring(4, trimmedLine.length - 3));
      } else if (trimmedLine.startsWith('<?')) {
        contentHandler.processingInstruction(
            trimmedLine.substring(2, trimmedLine.length - 1));
      } else if (trimmedLine.startsWith('</')) {
        final closingTag = trimmedLine.substring(2, trimmedLine.length - 1);
        if (elementStack.isEmpty || elementStack.last.name != closingTag) {
          throw FormatException(
              'Invalid document: Unexpected closing tag $closingTag');
        }
        final closedElement = elementStack.removeLast();
        contentHandler.endElement(closedElement);
      } else if (trimmedLine.endsWith('/>')) {
        final selfClosingTag = trimmedLine.substring(1, trimmedLine.length - 2);
        final parts = selfClosingTag.split(' ');
        final name = parts[0];
        final attributes = _parseAttributes(parts);
        final selfClosingElement = XmlElement(name, attributes: attributes);
        contentHandler.startElement(selfClosingElement);
        contentHandler.endElement(selfClosingElement);
      } else if (trimmedLine.startsWith('<')) {
        final openingTag = trimmedLine.substring(1);
        final parts = openingTag.split('>');
        final tagContent = parts[0];
        final tagLines = tagContent.split(' ');
        final name = tagLines[0];
        final attributes = _parseAttributes(tagLines);
        final element = XmlElement(name, attributes: attributes);

        if (elementStack.isNotEmpty) {
          final parent = elementStack.last;
          parent.addToChildren(element);
        }

        contentHandler.startElement(element);

        if (trimmedLine.endsWith('>')) {
          elementStack.add(element);
        } else {
          contentHandler.endElement(element);
        }
      } else {
        if (elementStack.isNotEmpty) {
          final parent = elementStack.last;
          parent.text = trimmedLine;
        } else if (trimmedLine.isNotEmpty) {
          throw FormatException(
              'Invalid document: Text content outside of an element');
        }
      }
    }

    if (elementStack.isNotEmpty) {
      throw FormatException(
          'Invalid document: Unclosed element(s) ${elementStack.map((e) => e.name)}');
    }
  }

  Map<String, String> _parseAttributes(List<String> parts) {
    final attributes = <String, String>{};

    for (var i = 1; i < parts.length; i++) {
      final attribute = parts[i].split('=');
      final key = attribute[0];
      final value = attribute[1].replaceAll('"', '');
      attributes[key] = value;
    }

    return attributes;
  }
}
