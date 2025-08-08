extends Node
class_name Health

@export var max_hp:int = 50
@export var popup_height: float = 1.6
@export var floating_text_scene: PackedScene  # assign FloatingText.tscn in editor (or leave; we set a fallback)

var hp:int = 0
var is_dead:bool = false

signal damaged(amount:int, hp:int, max_hp:int)
signal died()

func _ready() -> void:
	hp = max_hp
	if floating_text_scene == null:
		# fallback so you don't forget to hook it
		if ResourceLoader.exists("res://scenes/fx/FloatingText.tscn"):
			floating_text_scene = load("res://scenes/fx/FloatingText.tscn")

func apply_damage(amount:int, source:Node=null) -> void:
	if is_dead: return
	hp = max(0, hp - int(amount))
	damaged.emit(amount, hp, max_hp)
	# Debug:
	# print("%s took %d dmg -> %d/%d" % [owner.name, amount, hp, max_hp])

	# Juice (only shake/float when the player caused it)
	_do_hit_fx(amount, source)

	if hp == 0:
		is_dead = true
		died.emit()
		_die()

func _die() -> void:
	if owner and is_instance_valid(owner):
		owner.queue_free()

func _do_hit_fx(amount:int, source:Node) -> void:
	# quick hit flash on meshes (always)
	_flash_meshes()

	# if the player dealt the damage, do shake + floating text
	if source and source.is_in_group("player"):
		# mild screenshake
		get_tree().call_group("camera", "shake", 0.08, 0.12)

		# floating damage number
		if floating_text_scene:
			var ft = floating_text_scene.instantiate()
			var root = get_tree().current_scene
			root.add_child(ft)
			if ft is Node3D:
				ft.global_position = owner.global_transform.origin + Vector3(0, popup_height, 0)
			if ft.has_method("show_value"):
				# Red-ish for damage; tweak to taste
				ft.show_value(amount, Color(1, 0.4, 0.4, 1.0))

func _collect_visual_nodes(n: Node) -> Array[Node3D]:
	var arr: Array[Node3D] = []
	for c in n.get_children():
		# Gather common 3D visual nodes
		if c is MeshInstance3D or c is SpriteBase3D or c is Label3D:
			arr.append(c as Node3D)
		arr.append_array(_collect_visual_nodes(c))
	return arr

func _flash_meshes() -> void:
	var visuals: Array[Node3D] = _collect_visual_nodes(owner)

	# Split by type: MeshInstance3D gets an overlay; Sprite/Label3D can use modulate
	var meshes: Array[MeshInstance3D] = []
	var modulatables: Array[Node] = []
	for v in visuals:
		if v is MeshInstance3D:
			meshes.append(v as MeshInstance3D)
		elif v is SpriteBase3D or v is Label3D:
			modulatables.append(v)

	# Create one shared overlay material for the flash (cheap & easy)
	var flash := StandardMaterial3D.new()
	flash.albedo_color = Color(1.0, 0.5, 0.5, 1.0)
	flash.emission_enabled = true
	flash.emission = Color(1.0, 0.3, 0.3, 1.0)
	flash.emission_energy_multiplier = 1.2

	# Apply overlay to meshes
	for m in meshes:
		m.material_overlay = flash

	# For sprites/labels in 3D, use modulate (they support it)
	var originals: Array = []
	for n in modulatables:
		# store original color and tint it
		originals.append([n, n.modulate])
		n.modulate = Color(1.0, 0.5, 0.5, 1.0)

	# brief flash
	await get_tree().create_timer(0.06).timeout

	# Revert
	for m in meshes:
		if is_instance_valid(m):
			m.material_overlay = null
	for pair in originals:
		var n: Node = pair[0]
		var col: Color = pair[1]
		if is_instance_valid(n):
			n.modulate = col
