// Return an emoji for a given item name if a match is found.
String? emojiForItemName(String name) {
  if (name.isEmpty) return null;
  final key = name.toLowerCase();

  // map common grocery items to emoji
  const map = {
    'banana': '🍌',
    'bananas': '🍌',
    'apple': '🍎',
    'apples': '🍎',
    'milk': '🥛',
    'egg': '🥚',
    'eggs': '🥚',
    'bread': '🍞',
    'cheese': '🧀',
    'butter': '🧈',
    'coffee': '☕',
    'tea': '🍵',
    'rice': '🍚',
    'pasta': '🍝',
    'chicken': '🍗',
    'beef': '🥩',
    'salad': '🥗',
    'tomato': '🍅',
    'potato': '🥔',
    'onion': '🧅',
    'yogurt': '🥛',
    'cereal': '🥣',
    'oil': '🍾',
  };

  // exact or contains match
  if (map.containsKey(key)) return map[key];
  for (final k in map.keys) {
    if (key.contains(k)) return map[k];
  }
  return null;
}

// Return an emoji for a category name or fallback to item mapper.
String? emojiForCategoryName(String name) {
  if (name.isEmpty) return null;
  final key = name.toLowerCase();

  const catMap = {
    'fruits': '🍎',
    'fruit': '🍎',
    'vegetables': '🥬',
    'vegetable': '🥬',
    'dairy': '🥛',
    'bakery': '🥐',
    'pantry': '🥫',
    'protein': '🍗',
    'frozen': '🧊',
    'beverages': '🥤',
    'snacks': '🍿',
    'produce': '🧺',
    'household': '🧼',
    'cleaning': '🧴',
    'meat': '🥩',
    'seafood': '🦞',
  };

  if (catMap.containsKey(key)) return catMap[key];
  for (final k in catMap.keys) {
    if (key.contains(k)) return catMap[k];
  }

  // fallback to item mapping which can catch things like "banana" in a
  // generated category or custom category names.
  return emojiForItemName(name);
}
