extends Label3D

@export var lifetime: float = 0.8
@export var rise_speed: float = 1.6

var _age: float = 0.0
var _max: float = 0.8

func _ready():
	_max = lifetime
	fixed_size = true
	# default style
	modulate = Color(1, 1, 1, 1)

func show_value(value: int, color: Color = Color(1, 1, 1, 1)) -> void:
	text = str(value)
	modulate = color

func _process(delta: float) -> void:
	global_position.y += rise_speed * delta
	_age += delta
	var a = clamp(1.0 - (_age / _max), 0.0, 1.0)
	var m = modulate
	m.a = a
	modulate = m
	if _age >= _max:
		queue_free()
