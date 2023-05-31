class XmlElement {
  String name;
  Map<String, String> attributes;
  List<XmlElement>? children;
  String text;

  XmlElement(
    this.name, {
    this.attributes = const {},
    this.children,
    this.text = '',
  });

  void addToChildren(XmlElement element) {
    if (children != null) {
      children!.add(element);
      return;
    }

    children = [element];
  }
}
