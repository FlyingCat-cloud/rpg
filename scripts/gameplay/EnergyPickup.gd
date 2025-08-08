extends Area3D
@export var amount: float = 40.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_node("FusionController"):
		var fusion = body.get_node("FusionController")
		if fusion and fusion.has_method("add_energy"):
			fusion.add_energy(amount)
	queue_free()
