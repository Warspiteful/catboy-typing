extends CanvasLayer

export(Array, String, FILE, "*.json") var dialogue_file
signal dialogue_end(conversation_number)

var dialogues = []
var current_dialogue_id = 0
var current_converation_id = -1
func _ready():
	$NinePatchRect.visible = false

func play():
	$NinePatchRect.visible = true
	dialogues = load_dialogues()	
	current_dialogue_id = -1
	next_line()

func _input(event):
	if event.is_action_pressed("game_usage"):
		next_line()		

func next_line():
	current_dialogue_id += 1
	if(current_dialogue_id >= len(dialogues)):
		$NinePatchRect.visible = false
		emit_signal("dialogue_end",1)
		return
	$NinePatchRect/Name.text = dialogues[current_dialogue_id]['name']
	$NinePatchRect/Message.text = dialogues[current_dialogue_id]['text']
	
func load_dialogues():
	var file = File.new()
	if file.file_exists(dialogue_file[current_converation_id]):
		file.open(dialogue_file[current_converation_id],file.READ)
		return parse_json(file.get_as_text())


func _on_Main_dialogue_start(conversation_number):
	current_converation_id = conversation_number
	play()
