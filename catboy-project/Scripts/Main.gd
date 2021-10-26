extends Spatial

var Enemy = preload("res://Enemy.tscn")


var active_enemy = null;
var current_letter_index: int = -1
var difficulty :int = 1
var enemies_killed : int = 0

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_timer = $DifficultyTimer
onready var difficulty_value = $CanvasLayer/VBoxContainer/BottomRow/BottomRow/DifficultyLabelValue
onready var killed_value = $CanvasLayer/VBoxContainer/TopRow/TopRowH/EnemiesKilledValue
onready var game_over_screen = $CanvasLayer/GameOverScreen
onready var game_pause_screen = $CanvasLayer/GamePauseScreen

func _ready():
	OS.set_ime_active(true)
	start_game()
	
func find_new_active_enemy(typed_character: String):
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_char = prompt.substr(0,1)
	
		if next_char == typed_character:
			active_enemy = enemy
			current_letter_index = 1
			active_enemy.set_next_character(current_letter_index)
			return
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_pressed():
		var typed_event = event as InputEventKey

		var key_typed = PoolByteArray([typed_event.scancode]).get_string_from_utf8().to_lower()

		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_char = prompt.substr(current_letter_index,1)

			if key_typed == next_char:
				print("successfully typed %s " % key_typed)
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				print(prompt.length())
				if current_letter_index == prompt.length()-1:
					print("Killed Enemy!")
					current_letter_index = -1
					active_enemy.queue_free()
					active_enemy = null
					enemies_killed += 1
					killed_value.text = str(enemies_killed)
			else:
				print("Incorrectly type %s instead of %s" % [key_typed, next_char])
			
		
		


func _on_SpawnTimer_timeout() -> void:
	spawn_enemy()
	
func spawn_enemy():

	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_transform = spawns[index].global_transform
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)

func _on_DifficultyTimer_timeout():
	if difficulty >= 20:
		difficulty_timer.stop()
		difficulty = 20
		return
		
	difficulty += 1
	difficulty_value.text = str(difficulty)
	GlobalSignals.emit_signal("difficulty increased", difficulty)
	print("Difficulty increased to %d" % difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
		
func game_over():
	game_over_screen.show()
	active_enemy = null
	current_letter_index = -1
	spawn_timer.stop()
	difficulty_timer.stop()
	for enemy in enemy_container.get_children():
		enemy.queue_free()
		
	
func start_game():
	game_pause_screen.hide()
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	difficulty_value.text = str(0)
	killed_value.text = str(0)
	randomize()
	spawn_enemy()
	spawn_timer.start()
	difficulty_timer.start()
	pass
	
func _on_PauseButton_pressed():
	get_tree().paused = true
	game_pause_screen.show()

func _on_ResumeButton_pressed():
	get_tree().paused = false
	game_pause_screen.hide()

func _on_RestartButton_pressed():
	start_game()
