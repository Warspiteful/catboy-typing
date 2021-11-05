extends Spatial

#------------------------#
#References To Other Nodes
#------------------------# 

# Get Text Label
onready var prompt = $Enemy/Viewport/Control/Panel/RichTextLabel

# Get Attack Timer
onready var attack_timer = $AttackTimer  

# Get Text Value of Label
onready var prompt_text = prompt.text


# Holds Color Values
export (Color) var blue = Color("#4682b4")
export (Color) var green = Color("#639765")
export (Color) var red = Color("#a65455")

# Controls Important Values Regarding Enemy Functions
export (float) var speed = 0.01
export (int) var damage = 1
export (float) var attack_distance = -3


# Important Variables
## Tracks if Enemy is Attacking
## - Informs whether to start attacking timer
var attacking : bool = false
## Difficulty Tracker
## - Determines Speed
var difficulty : int = 0
## Damage Queue
## - Tracks any damage being dealt by enemy
var damage_queue = []

# Ready Function
## Called at initialization
func _ready():

	# Gets Prompt from Prompt List
	prompt_text = PromptList.get_prompt()
	
	# Sets BBCode for Prompt
	prompt.parse_bbcode(set_center_tags(prompt_text))
	
	## Connects function to difficulty increase
	GlobalSignals.connect("difficulty_increase", self, "handle_difficulty_increased")

# Get Prompt Function
# - Returns Stored String
func get_prompt() -> String:
	# Returns Text stored in Label
	return prompt.text

# Physics Process
# - Called Every Frame
func _physics_process(delta):
	
	# Check if the enemy has reached a designated attacking distance 
	# - If not, continue moving
	# - If at designated distance, then don't move and start attacking
	if(translation.z < attack_distance):
		
		# Moves Enemy Closer
		transform = transform.translated(Vector3(0,0,speed)) 
	
	elif(attacking == false):
		
		# Debug Console
		print("Attacking!")
		
		# Start Attacking
		attack_timer.start()
		attacking = true

# Set Next Character
# -  Handles Formatting for characters in label
func set_next_character(next_character_index : int):
	
	# Plays Feedback Animation when Character Index is advanced
	if(next_character_index != 0):
		$Enemy/AnimationPlayer.stop()
		$Enemy/AnimationPlayer.play("hit")
		
	# OH GOD - Formatting Handling
	# - Blue: All character Text already typed
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0,next_character_index) + get_bbcode_end_color_tag()
	
	# - Green: Current Letter to Type
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index,1) + get_bbcode_end_color_tag()
	
	# - Red: All characters left to type
	var red_text = ""
	if(next_character_index != prompt_text.length()):
			red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index+1,prompt_text.length()-next_character_index+1) + get_bbcode_end_color_tag()
			
	# Parse bbcode
	prompt.parse_bbcode(set_center_tags(blue_text + green_text + red_text))

# Set Center Tags
# - Handles setting center tags 
func set_center_tags(text_to_center : String) -> String:
	return "[center]" + text_to_center + "[/center]"

# Get bbcode color tag
# - Sets bbcode for the passed in color
func get_bbcode_color_tag(color : Color) -> String:
	return "[color=#" + color.to_html(false) + "]"
	
# Get bbcode end color tag 
# - End Color Tag 
func get_bbcode_end_color_tag() -> String:
	return "[/color]"

# Set Difficulty
# - Handles Internal Difficulty   
func set_difficulty(difficulty : int):
	handle_difficulty_increased(difficulty)
		
# Handle Difficulty Increased
# - Sets Speed According to Difficulty
func handle_difficulty_increased(new_difficulty : int):
	var new_speed = speed + (0.005 * new_difficulty)
	speed = clamp(new_speed, speed, .02)
	
# Handles Level Increasing
func handle_level_increased(new_level : int):
	difficulty = new_level
	
# Reset Timer Function
# Starts Attack Timer 
func resetTimer():
	$AttackTimer.start()

# Attack Timer Timeout
# - Attack Timer Times Out
func _on_AttackTimer_timeout():
	print("Damage!")
	damage_queue.append(damage)
	print(damage_queue)
	
	
