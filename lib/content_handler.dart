import 'package:xml_parser/xml_element.dart';

abstract class XmlContentHandler {
  void startElement(XmlElement element);
  void endElement(XmlElement element);
  void comment(String comment);
  void processingInstruction(String target);
}

class MyContentHandler implements XmlContentHandler {
  List<XmlElement> elements = [];

  void startElement(XmlElement element) {
    elements.add(element);
  }

  void endElement(XmlElement element) {
    // Do any necessary processing with the element
  }

  void comment(String comment) {
    // Handle comments as needed
  }

  void processingInstruction(String target) {
    // Handle processing instructions as needed
  }
}

String formatXmlString(String xmlString) {
  final StringBuffer formattedXml = StringBuffer();
  final StringBuffer currentElement = StringBuffer();
  final List<String> openElements = [];

  bool insideTag = false;
  bool selfClosingTag = false;
  for (int i = 0; i < xmlString.length; i++) {
    final char = xmlString[i];

    if (char == '<') {
      insideTag = true;
      if (currentElement.isNotEmpty) {
        formattedXml.writeln(currentElement.toString().trim());
        currentElement.clear();
      }
      continue;
    }

    if (char == '>') {
      insideTag = false;
      final elementContent = currentElement.toString().trim();

      if (elementContent.endsWith('/')) {
        selfClosingTag = true;
        final elementName =
            elementContent.substring(0, elementContent.length - 1).trim();
        formattedXml.writeln('<$elementName/>');
      } else if (elementContent.startsWith('/')) {
        final elementName = elementContent.substring(1).trim();
        formattedXml.writeln('\n</$elementName>');
      } else {
        selfClosingTag = false;
        final elementName = elementContent.split(' ')[0].trim();
        formattedXml.writeln('<$elementName>');
        openElements.add(elementName);
      }

      currentElement.clear();
      continue;
    }

    if (insideTag) {
      currentElement.write(char);
    } else {
      if (selfClosingTag) {
        formattedXml.writeln();
        selfClosingTag = false;
      }
      formattedXml.write(char);
    }
  }

  if (currentElement.isNotEmpty) {
    formattedXml.writeln(currentElement.toString().trim());
  }

  // openElements.reversed.forEach((elementName) {
  //   formattedXml.writeln('</$elementName>');
  // });

  return formattedXml.toString();
}
