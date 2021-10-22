extends Spatial

var active_enemy = null;
var current_letter_index: int = -1
onready var enemy_container = $EnemyContainer
func ready():
	OS.set_ime_active(true)
	
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
				if current_letter_index == prompt.length()-1:
					print("Killed Enemy!")
					current_letter_index = -1
					active_enemy.queue_free()
					active_enemy = null
			else:
				print("Incorrectly type %s instead of %s" % [key_typed, next_char])
			
		
		