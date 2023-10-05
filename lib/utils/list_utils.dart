class ListUtils{
  static List getElementsAppearInBothList(List l1, List l2) {
    return l1.where((e) {
      // Pick any element in l1 and be contained in l2
      return l2.contains(e);
    }).toList();
  }

  static List<T> getElementsDifferentInBothList<T>(List<T> l1, List<T> l2){
    var set1 = Set.from(l1);
    var set2 = Set.from(l2);
    return List<T>.from(set1.difference(set2));
  }

  static List<String> listToLowerCase(List<String> list){
    return list.map((element) => element.toLowerCase()).toList();
  }
}