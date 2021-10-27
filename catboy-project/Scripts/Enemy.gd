extends MeshInstance

onready var prompt = $RichTextLabel
onready var prompt_text = prompt.text
export (Color) var blue = Color("#4682b4")
export (Color) var green = Color("#639765")
export (Color) var red = Color("#a65455")

export (float) var speed = 0.01
export (int) var damage = 1
export (float) var attack_distance = -3

var attacking : bool = false

var damage_queue = []

func _ready():
	prompt_text = PromptList.get_prompt()
	prompt.parse_bbcode(set_center_tags(prompt_text))
	GlobalSignals.connect("difficulty increased", self, "handle_difficulty_increased")
	
	
func get_prompt() -> String:
	return prompt.text

func _physics_process(delta):
	if(translation.z < attack_distance):
		transform = transform.translated(Vector3(0,speed,0)) 
	elif(attacking == false):
		$AttackTimer.start()
		attacking = true
	
func set_next_character(next_character_index : int):
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0,next_character_index) + get_bbcode_end_color_tag()
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index,1) + get_bbcode_end_color_tag()
	var red_text = ""
	if(next_character_index != prompt_text.length()):
			red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index+1,prompt_text.length()-next_character_index+1) + get_bbcode_end_color_tag()
	prompt.parse_bbcode(set_center_tags(blue_text + green_text + red_text))
	
func set_center_tags(text_to_center : String) -> String:
	return "[center]" + text_to_center + "[/center]"
		
func get_bbcode_color_tag(color : Color) -> String:
	return "[color=#" + color.to_html(false) + "]"
	
func get_bbcode_end_color_tag() -> String:
	return "[/color]"

func set_difficulty(difficulty : int):
	handle_difficulty_increased(difficulty)
		
func handle_difficulty_increased(new_difficulty : int):
	var new_speed = speed + (0.005 * new_difficulty)
	speed = clamp(new_speed, speed, .02)
	
func resetTimer():
	$AttackTimer.start()


func _on_AttackTimer_timeout():
	 damage_queue.append(damage)
	
	
