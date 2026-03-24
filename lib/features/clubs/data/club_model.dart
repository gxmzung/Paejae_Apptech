class ClubModel {
  final String id;
  final String name;
  final String category;
  final String summary;
  final String description;
  final String location;
  final String contact;
  final String instagram;
  final bool recruiting;
  final List<String> meetingDays;
  final List<String> tags;
  final String imageAsset;

  const ClubModel({
    required this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.description,
    required this.location,
    required this.contact,
    required this.instagram,
    required this.recruiting,
    required this.meetingDays,
    required this.tags,
    required this.imageAsset,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      contact: (json['contact'] ?? '').toString(),
      instagram: (json['instagram'] ?? '').toString(),
      recruiting: json['recruiting'] == true,
      meetingDays: ((json['meetingDays'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      tags: ((json['tags'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      imageAsset: (json['imageAsset'] ?? '').toString(),
    );
  }
}