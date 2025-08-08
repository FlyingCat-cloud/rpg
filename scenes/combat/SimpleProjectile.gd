extends RigidBody3D

var velocity: Vector3 = Vector3.ZERO
var damage: int = 10
var instigator: Node = null   # renamed from 'owner' to avoid name clash

func set_velocity(v: Vector3) -> void:
	velocity = v

func set_damage(d: int) -> void:
	damage = d

func set_instigator(o: Node) -> void:
	instigator = o

func _ready():
	# Ensure signals are connected (and you enabled Contact Monitor in the Inspector)
	body_entered.connect(_on_body_entered)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = velocity

func _on_body_entered(body: Node) -> void:
	if body == instigator:
		return
	var h = _find_health(body)
	if h:
		h.apply_damage(damage, instigator)
		queue_free()

# Helper to locate a Health component (class_name Health) on the node or its children
func _find_health(node: Node):
	# Directly on the node?
	if node is Health:
		return node
	# Child named "Health"?
	var direct = node.get_node_or_null("Health")
	if direct and direct is Health:
		return direct
	# Any child with Health script?
	for c in node.get_children():
		if c is Health:
			return c
	return null
