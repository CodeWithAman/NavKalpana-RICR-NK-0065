String capitalizeFirstLetterOfEachWord(String input) {
  List<String> words = input.split(' ');
  List<String> capitalizedWords = words.map((word) {
    if (word.isEmpty) {
      return word; // Return empty string as is
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();
  return capitalizedWords.join(' ');
}
