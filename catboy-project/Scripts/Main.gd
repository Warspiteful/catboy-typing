extends Spatial


# Enemy List
# - Holds all enemies to be spawned 
var Enemy = preload("res://Enemy.tscn")
var Enemy2 = preload("res://Enemy.tscn")
var Enemy3 = preload("res://Enemy.tscn")
var Enemy4 = preload("res://Enemy.tscn")

# Dialogue Start Signal
# - Communicates with DialoguePlayer to start conversation
#   given by converation_number, stored in array found in
#	DialoguePlayer 
signal dialogue_start(conversation_number)

#-------------------#
#Important Variables# 
#-------------------#

var active_enemy = null;
# Holds the current enemy being typed

var current_letter_index: int = -1
# Holds the index in the word being typed

var difficulty :int = 1
# Holds the tracker for difficulty
# - Difficulty is used to scale spawn and movement speed

var enemies_killed : int = 0
# Tracks how many enemies have been killed

var health : int = 5 
# Tracks the health of the player
# - Used for loss condition

var level : int = 0
# Tracks the level of the game
# - Used to increment difficulty of Word List

#-------------------------#
#References to Other Nodes# 
#-------------------------#

## Enemy Spawning
onready var enemy_container = $EnemyContainer
# Holds all active enemies
# - Used to iterate quickly through all enemy instances

onready var spawn_timer = $SpawnTimer
# Timer used to trigger spawning of enemies
# - When timed out, calls  _on_SpawnTimer_timeout()

onready var difficulty_timer = $DifficultyTimer
# Timer used to increment difficulty
# - When timed out, calls  _on_DifficultyTimer_timeout()

## UI
### Used to write variable values to UI items
onready var difficulty_value = $CanvasLayer/VBoxContainer/BottomRow/BottomRow/DifficultyLabelValue
onready var health_value = $CanvasLayer/VBoxContainer/TopRow/TopRowH/HealthVal
onready var killed_value = $CanvasLayer/VBoxContainer/TopRow/TopRowH/EnemiesKilledValue

## Screens
onready var game_over_screen = $CanvasLayer/GameOverScreen
onready var game_pause_screen = $CanvasLayer/GamePauseScreen


#Ready Function
# - Called Automatically when Node is Initialized
func _ready():

	# Set mode for handling key inputs - Don't worry about this
	OS.set_ime_active(true)
	
	# Initializes Game
	start_game()
	
# Start Game Function
# - Sets all starting conditions for game
# - Resets to base conditions
func start_game():
	
	# Hides all menus
	game_pause_screen.hide()
	game_over_screen.hide()
	
	# Plays starting dialogue
	playDialogue()
	
	# Resets all variables 
	difficulty = 0
	enemies_killed = 0
	difficulty_value.text = str(0)
	killed_value.text = str(0)
	health_value.text = str(health)
	
	# Randomizes Seed - Prevents Identical RNG
	# - Built-in Function
	randomize()
	
	# Starts Timers 
	spawn_timer.start() # Starts timer for spawning
	difficulty_timer.start() # Starts timer for incrementing difficulty
	
	# Spawns first enemy to start game
	# - Otherwise, would need to wait for timer to finish for first
	#	enemy to spawn
	spawn_enemy()
	
# Process Function
# - Called Every Frame Automatically
# - Used to track health and damage
# - Checks loss condition
func _process(delta):
	
	# Check Loss Condition
	if(health <= 0):
		game_over()
		return
	
	# Process Damage
	## Iterate through all enemies
	for enemy in enemy_container.get_children():
		## Process all values held in a queue - continue while not empty
		### Damage is processed like items in a line
		while(!enemy.damage_queue.empty()): 
			
			
			## Subtract damage from health and remove from queue
			health -= enemy.damage_queue.pop_back();
			
			## Update text shown in UI
			health_value.text = str(health);

# Input Function
# - Called Every time an input is processed
# 	- This means called every time a key is pressed for our purposes
func _input(event: InputEvent):
	
	# Checked if Event was a key being typed
	# - This allows us to ignore all other events 
	if event is InputEventKey and not event.is_pressed():
		
		# Take in event into a variable
		var typed_event = event as InputEventKey

		# Convert event into a character - I don't understand this either
		var key_typed = PoolByteArray([typed_event.scancode]).get_string_from_utf8().to_lower()

		# Checks if an enemy is being actively targeted
		##	-	This means - did the user already kill the previous
		##		enemy and trying to type in a new one?		
		if active_enemy == null:
			# If so, search for an enemy using the typed-in character
			find_new_active_enemy(key_typed)
		else:
			# Come here if an enemy has already been found and this
			# 	key press is part of a word that is being completed.
			# The found enemy has been set to active_enemy. See the 
			# 	find_new_active_enemy for more information.
			
			# Get the string prompt of the active_enemy
			var prompt = active_enemy.get_prompt()
			
			# Get the value of the character that must be typed next
			# - current_letter_index tracks where we are in a word
			# - 1 means we only take one character 
			var next_char = prompt.substr(current_letter_index,1)
			
			# Check if the key typed is equal to the next character
			if key_typed == next_char:
				
				# Prints to Console for Debugging Purposes
				print("successfully typed %s " % key_typed)
				
				# Increments index in the word to next character
				current_letter_index += 1
				
				# Handles Visual Tracking in Label - documented more in Enemy.gd
				active_enemy.set_next_character(current_letter_index)
				
				# Check if entire word has been typed
				# - If tracker has gone through entire word
				if current_letter_index == prompt.length():
					
					# Printing for Debug Purposes
					print("Killed Enemy!")
					
					# Reset current_letter_index
					# - Arrays start at 0, so should set to -1 to be safe
					current_letter_index = -1
					
					# Resets Active Enemy
					## Delete Enemy Instance
					active_enemy.queue_free()
					## Nulls Active_Enemy, enables searching again
					active_enemy = null
					
					# Update Enemy Kill UI 
					## Increments Enemy killed tracker
					enemies_killed += 1
					## Updates UI element
					killed_value.text = str(enemies_killed)
			else:
				# If typed character is not equal to next char, print for debug
				print("Incorrectly type %s instead of %s" % [key_typed, next_char])

# Spawn Enemy Function
## - Handles the instantiation of enemy objects 
func spawn_enemy():
	
	# Creates an instance of the enemy
	var enemy_instance = Enemy.instance()
	
	# Sets its position to a random place within view
	# - Numbers found through experimentation
	enemy_instance.set_translation(Vector3(rand_range(-3,3),rand_range(-3,0),-6))
	
	# Set instance to a child of enemy_container
	# - This allows us to quickly iterate through all existing instances
	enemy_container.add_child(enemy_instance)
	
	# Tells instance the current difficulty
	## This allows it to get up to the current speed scale
	enemy_instance.set_difficulty(difficulty)
	
# Find New Active Enemy
## - Called when a key is typed and we have no active enemy (no word mid-completion)
## - Need to find an enemy to target
func find_new_active_enemy(typed_character: String):
	
	# Iterates through all enemies
	# - All enemies are made children of enemy_container during spawning
	for enemy in enemy_container.get_children():
		
		# Get the prompt stored in the enemy
		# - What word prompt do they have?	
		var prompt = enemy.get_prompt()
		
		# Get the first character of the above-mentioned prompt
		var next_char = prompt.substr(0,1).to_lower()

		# Check if typed character is equal to above-mentioned character
		if next_char == typed_character:
			# If so...
			
			# This is now the enemy we're fighting
			# - All subsequent key types will be checking against this enemy
			active_enemy = enemy
			
			# Set character tracker to the second character of the word
			current_letter_index = 1
			
			# Update UI label - See Enemy.gd for information
			active_enemy.set_next_character(current_letter_index)
			
			# Exit function
			return
					
# Game Over Function
## - Called in _process when loss condition is hit		
func game_over():
	
	# Display Game Over Screen
	game_over_screen.show()
	
	# Disable all game variables
	active_enemy = null
	current_letter_index = -1
	
	# Stop Timers
	spawn_timer.stop()
	difficulty_timer.stop()
	
	# Delete All Enemies
	for enemy in enemy_container.get_children():
		enemy.queue_free()
		

# Play Dialogue Function
# - Communicates with DialoguePlayer.gd
# - Pauses Gameplay to allow dialogue to play
func playDialogue():
	
	# Pauses processing
	get_tree().paused = true
	
	# Tells DialoguePlayer to play dialogue
	# - Conversation number correlates to current level
	# - For information on level, see _on_DifficultyTimer_timeout 
	emit_signal("dialogue_start",level)
	
# Spawn Timer Timeout
# - Called when Spawn Timer Elapses
func _on_SpawnTimer_timeout() -> void:
	# Call spawn_enemy to spawn a new enemy
	spawn_enemy()

# Difficulty Timer Timeout
# - Called when Difficulty Timer Elapses
# - Handles incrementing Difficulty
func _on_DifficultyTimer_timeout():
	if difficulty >= 10:
		if level < 2:
			level += 1
			difficulty = 0
			print("Level increased to %d" % level)
			playDialogue()
			PromptList.handle_level_increased(level)
			spawn_timer.wait_time = spawn_timer.wait_time + 1
			return
		else:
			difficulty = 10
			difficulty_timer.stop()
			return
	
	difficulty += 1
	difficulty_value.text = str(difficulty)
	GlobalSignals.emit_signal("difficulty_increase", difficulty)
	print("Difficulty increased to %d" % difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
	
func _on_PauseButton_pressed():
	get_tree().paused = true
	game_pause_screen.show()

func _on_ResumeButton_pressed():
	get_tree().paused = false
	game_pause_screen.hide()

func _on_RestartButton_pressed():
	print("Restarted")
	start_game()

func _on_DialoguePlayer_dialogue_end(conversation_number):
	get_tree().paused = false
	
