class EmergencyGuide {
  final String id;
  final String category;
  final String? imageContent1;
  final String? imageContent2;
  final String? imageContent3;
  final String textContent1;
  final String textContent2;
  final String textContent3;

  EmergencyGuide({
    required this.id,
    required this.category,
    this.imageContent1,
    this.imageContent2,
    this.imageContent3,
    required this.textContent2,
    required this.textContent3,
    required this.textContent1,
  });

  factory EmergencyGuide.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return EmergencyGuide(
      id: doc.id,
      category: data['category'] ?? 'Emergency Guide',
      imageContent1: data['imageContent1'],
      imageContent2: data['imageContent2'],
      imageContent3: data['imageContent3'],
      textContent1: data['textContent1'] ?? '',
      textContent2: data['textContent2'] ?? '',
      textContent3: data['textContent3'] ?? '',
    );
  }
}