extends Camera3D
class_name ScreenShake

var _shake_time: float = 0.0
var _shake_duration: float = 0.0
var _shake_amp: float = 0.0
var _base_transform: Transform3D

func _ready():
	_base_transform = global_transform
	add_to_group("camera") # so we can call shake from anywhere

func shake(amp: float, duration: float) -> void:
	_shake_amp = max(_shake_amp, amp)
	_shake_duration = max(_shake_duration, duration)
	_shake_time = 0.0

func _process(delta: float) -> void:
	if _shake_duration > 0.0:
		_shake_time += delta
		var t = 1.0 - clamp(_shake_time / _shake_duration, 0.0, 1.0)
		var offset = Vector3(randf() - 0.5, randf() - 0.5, 0.0) * _shake_amp * t
		global_transform.origin = _base_transform.origin + offset
		if _shake_time >= _shake_duration:
			_shake_duration = 0.0
			global_transform = _base_transform
	else:
		# keep updating base so shake applies to the current position as you move
		_base_transform = global_transform
