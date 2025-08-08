extends Node
class_name AbilitySystem

@export var cast_origin_path:NodePath  # set to a Marker3D on the Player
@export var skills:Array[Skill] = []   # fill from the active card later

var _cooldowns:Array[float] = []
var _cast_origin:Node3D

func _ready():
	_cooldowns.resize(skills.size())
	for i in _cooldowns.size():
		_cooldowns[i] = 0.0
	if cast_origin_path != NodePath():
		_cast_origin = get_node(cast_origin_path)

func tick(delta:float) -> void:
	for i in _cooldowns.size():
		_cooldowns[i] = max(0.0, _cooldowns[i] - delta)

func can_cast(i:int, energy:float) -> bool:
	if i < 0 or i >= skills.size(): return false
	return _cooldowns[i] <= 0.0 and energy >= skills[i].energy_cost

func try_cast(i:int, fusion_controller:Node) -> bool:
	if i < 0 or i >= skills.size(): return false
	var s := skills[i]
	if _cooldowns[i] > 0.0: return false
	if not fusion_controller.is_fused: return false
	if fusion_controller.current_energy < s.energy_cost: return false

	# spend energy
	fusion_controller.spend_energy(s.energy_cost)

	match s.kind:
		Skill.Kind.MELEE:
			_cast_melee(s, fusion_controller)
		Skill.Kind.PROJECTILE:
			_cast_projectile(s, fusion_controller)
		Skill.Kind.BUFF:
			# placeholder: print and do nothing yet
			print("Buff cast:", s.display_name)

	_cooldowns[i] = s.cooldown
	return true

func _cast_melee(s:Skill, fusion_controller:Node) -> void:
	var owner_node:Node3D = fusion_controller.get_parent()

	var hitbox := Area3D.new()
	hitbox.monitoring = true
	hitbox.collision_layer = 0
	hitbox.collision_mask = 0
	hitbox.set_collision_layer_value(5, true)
	hitbox.set_collision_mask_value(3, true)
	
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = s.melee_radius
	shape.shape = sphere
	hitbox.add_child(shape)

	# Put it in front of the player
	var forward := -owner_node.global_transform.basis.z.normalized()
	var offset := forward * s.melee_range
	owner_node.get_tree().current_scene.add_child(hitbox)
	hitbox.global_transform.origin = owner_node.global_transform.origin + offset

	# Damage on contact (once; hitbox lives briefly)
	hitbox.body_entered.connect(func(body):
		if body == owner_node: return
		if body.has_node("Health"):
			var h = body.get_node("Health")
			if h and h.has_method("apply_damage"):
				h.apply_damage(int(s.power), owner_node)
	)

	# Cleanup after duration
	var t := get_tree().create_timer(s.melee_duration)
	t.timeout.connect(func(): if is_instance_valid(hitbox): hitbox.queue_free())


func _cast_projectile(s: Skill, fusion_controller: Node) -> void:
	if s.projectile_scene == null:
		print("No projectile scene set for", s.display_name)
		return
	if _cast_origin == null:
		var owner_node_fallback: Node3D = fusion_controller.get_parent()
		_cast_origin = owner_node_fallback

	var p := s.projectile_scene.instantiate()
	_cast_origin.get_tree().current_scene.add_child(p)

	p.global_transform = _cast_origin.global_transform
	var v := -_cast_origin.global_transform.basis.z * s.projectile_speed

	if p.has_method("set_velocity"):
		p.set_velocity(v)
	if p.has_method("set_damage"):
		p.set_damage(int(s.power))
	if p.has_method("set_instigator"):     # <-- renamed call
		p.set_instigator(fusion_controller.get_parent())


func _find_health(node: Node):
	# Health as the node itself?
	if node is Health:
		return node
	# Child named "Health"?
	var direct = node.get_node_or_null("Health")
	if direct and direct is Health:
		return direct
	# Any child carrying the Health script?
	for c in node.get_children():
		if c is Health:
			return c
	return null
