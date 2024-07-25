class SearchedItem {
  final String searchName;
  final String searchType;
  final String searchRef;
  double? searchPrice;
  String? searchEstablishment;
  double? searchLat;
  double? searchLon;

  SearchedItem(
      {required this.searchName,
      required this.searchType,
      required this.searchRef,
      this.searchEstablishment,
      this.searchPrice,
      this.searchLat,
      this.searchLon});
}
