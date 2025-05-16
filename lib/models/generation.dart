class Generation {
  final int id;
  final String name;
  final String region;

  Generation({
    required this.id,
    required this.name,
    required this.region,
  });

  factory Generation.fromJson(Map<String, dynamic> json) {
    return Generation(
      id: json['id'],
      name: json['name'],
      region: json['main_region']['name'],
    );
  }
}