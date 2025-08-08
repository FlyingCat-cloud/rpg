extends CharacterBody3D
@export var move_speed:float = 2.0
@export var aggro_distance:float = 8.0
@export var attack_distance:float = 1.6

var player:Node3D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player: return
	var d = global_position.distance_to(player.global_position)
	if d > aggro_distance: return
	if d > attack_distance:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		move_and_slide()
