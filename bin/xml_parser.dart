import 'dart:io';

import 'package:xml_parser/content_handler.dart';
import 'package:xml_parser/sax_parser.dart';
import 'package:xml_parser/xml_element.dart';

void main() {
  //read the file
  File file = File("file.xml");

  final xmlString = '''
  ${file.readAsStringSync()}
  ''';

  final saxParser = SaxParser();
  final contentHandler = MyContentHandler();

  final formattedXml = formatXmlString(xmlString);
  print(formattedXml);

  if (saxParser.isWellFormed(formattedXml)) {
    print('The XML document is well-formed.');
  } else {
    print('The XML document is not well-formed.');
    return;
  }

  try {
    saxParser.parse(formattedXml, contentHandler);
    print('The XML document is valid.');
    print('List of elements:');
    for (var element in contentHandler.elements) {
      printXmlElement(element, "\t");
    }
  } catch (e) {
    print('The XML document is invalid: ${e.toString()}');
  }
}

void printXmlElement(XmlElement element, [String prefix = '']) {
  print('$prefix${element.name}${_formatAttributes(element.attributes)}');

  if (element.text.isNotEmpty) {
    print('$prefix  ${element.text}');
  }

  if (element.children != null) {
    for (var child in element.children!) {
      printXmlElement(child, '$prefix  ');
    }
  }

  print('$prefix${element.name}');
}

String _formatAttributes(Map<String, String> attributes) {
  if (attributes.isEmpty) return '';

  final List<String> formattedAttributes = [];

  attributes.forEach((key, value) {
    formattedAttributes.add('$key="$value"');
  });

  return ' ' + formattedAttributes.join(' ');
}
