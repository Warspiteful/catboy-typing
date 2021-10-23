extends Node

var words = [
	"words",
	"testing",
	"hahahah"
]


func get_prompt() -> String:
	var word_index = randi() % words.size()

	
	var word = words[word_index]

	
	return word
	
	
