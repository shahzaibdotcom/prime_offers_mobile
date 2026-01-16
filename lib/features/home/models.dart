class HomeSection {
  final String title;
  final String type; // 'horizontal_list', 'banner', 'grid_small', 'carousel'
  final List<dynamic> data; 

  HomeSection({required this.title, required this.type, required this.data});

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      title: json['title'],
      type: json['type'],
      data: json['data'] ?? [],
    );
  }
}
