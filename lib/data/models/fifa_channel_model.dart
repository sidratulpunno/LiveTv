class FifaChannel {
  final String name;
  final String url;

  const FifaChannel({required this.name, required this.url});

  int get qualityScore {
    final n = name.toLowerCase();
    if (n.contains('4k')) return 5;
    if (n.contains('fhd') || n.contains('1080')) return 4;
    if (n.contains('720') || n.contains('hd')) return 3;
    if (n.contains('sd')) return 2;
    return 1;
  }
}
