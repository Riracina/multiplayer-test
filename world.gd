extends Node

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
