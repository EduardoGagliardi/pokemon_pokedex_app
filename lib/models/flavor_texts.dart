class FlavorTexts {
  final List<String> descriptions;

  FlavorTexts({
    required this.descriptions,
  });

  factory FlavorTexts.fromJson(Map<String, dynamic> json) {
    return FlavorTexts(
      descriptions: json["flavor_text_entries"]
      .where((entry) {
        return entry["language"]["name"] == "en";
      })
      .map((entry) => 
        entry["flavor_text"]
      ).whereType<String>().toList(),
    );
  }
}