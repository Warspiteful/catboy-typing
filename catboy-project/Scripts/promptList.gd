extends Node

var easyWords = [
"taco",
"cat",
"Crack",
"Kitty",
"Meow",
"Yarn",
"Milk",
"Rot",
"Suck",
"Hex",
"Curse",
"Spell",
"word",
"Piss",
"Fuck",
"Kitten"
]

var mediumWords = [
"stromboli",
"Futility",
"Laser",
"Keyboard",
"Feline",
"Suckle",
"Behoove",
"Nibling",
"Giblet",
"Fungus",
"Mildew",
"Berserk",
"jellicle"	
]
var hardWords = [
"Unnecessary",
"Imbecile",
"Evanescent",
"Obligation",
"Defenestration",
"Ailurophobia",
"Pussycat",
"Kerfuffle",
"Whippersnapper",
"Lackadaisical",
"discombobulate",
"Curmudgeon",
"woebegone"
]


var wordList = [easyWords,mediumWords,hardWords]

var level : int = 0
func handle_level_increased(new_level):

	level = new_level
	
func get_prompt() -> String:
	
	var words = wordList[level]
	
	var word_index = randi() % words.size()

	
	var word = words[word_index]

	
	return word
	
	
