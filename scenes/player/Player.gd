extends CharacterBody3D

@export var move_speed: float = 4.0

func _physics_process(delta: float) -> void:
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vec.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	input_vec = input_vec.normalized()

	var direction = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	move_and_slide()
