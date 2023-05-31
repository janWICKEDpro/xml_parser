import 'dart:io';

import 'package:xml_parser/content_handler.dart';
import 'package:xml_parser/xml_parser.dart';

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
      print(element.name);
    }
  } catch (e) {
    print('The XML document is invalid: ${e.toString()}');
  }
}
