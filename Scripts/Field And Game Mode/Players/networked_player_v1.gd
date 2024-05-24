extends Node3D
class_name network_player_v1

var speed := 0.0
var max_speed = 16
var is_local_authority : bool = false
var id_of_network_authority : int = 0

@export var cam : Camera3D

func _get_local_input() -> Dictionary:
	#var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#print("Input: " + str(input_vector))
	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	
	return input

func _network_process(input: Dictionary):
	var input_vector = input.get("input_vector", Vector2.ZERO)
	#print( name + " INPUT : " + str(input_vector) )
	#print( name + " owned by : " + str(get_multiplayer_authority()) )
	if (input_vector != Vector2.ZERO):
		#print("Local Player INPUT MOVING")
		if (speed < max_speed):
			speed += 1
		#position += input_vector * speed
		position.x += input_vector.x * speed
		position.z += input_vector.y * speed
	else:
		speed = 0.0


func _save_state() -> Dictionary:
		return{
			position = position,
			speed = speed,
		}

func _load_state(state: Dictionary):
	position = state["position"]
	speed = state["speed"]

#func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float):
	#if old_state.get('teleporting', false) or new_state.get('teleporting', false):
		#return
	#position = lerp(old_state['position'], new_state['position'], weight)
