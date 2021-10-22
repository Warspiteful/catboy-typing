extends Node2D

var active_enemy = null;
var current_letter_index: int = -1

func find_new_active_enemy():
	$Enemy.get_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_pressed():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if active_enemy == null:
			find_new_active_enemy()
			
		
		
