extends Node
class_name FusionController
# (keep your existing exports/signals)
@export var equipped_card:FusionCard
@export var max_energy: float = 100.0
@export var normal_speed: float = 4.0
@export var ability_system_path:NodePath  # NEW: set this in the editor

var current_energy: float = 0.0
var is_fused: bool = false

@onready var player := get_parent()
@onready var mesh: MeshInstance3D = player.get_node("MeshInstance3D")
var abilities:AbilitySystem

signal energy_changed(current: float, max: float)
signal fused_state_changed(is_fused: bool)
signal card_changed(card:FusionCard)

func _ready() -> void:
	current_energy = max_energy
	player.move_speed = normal_speed
	if ability_system_path != NodePath():
		abilities = get_node(ability_system_path)
	_apply_card_to_abilities()
	card_changed.emit(equipped_card)

func _process(delta: float) -> void:
	if is_fused and equipped_card:
		current_energy = max(0.0, current_energy - equipped_card.energy_drain_per_sec * delta)
		energy_changed.emit(current_energy, max_energy)
		if current_energy <= 0.0:
			revert()
	if abilities:
		abilities.tick(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("transform_toggle"):
		if is_fused:
			revert()
		else:
			transform()
	if abilities and is_fused:
		if event.is_action_pressed("skill_1"):
			abilities.try_cast(0, self)
		if event.is_action_pressed("skill_2"):
			abilities.try_cast(1, self)
		# later: skill_3, skill_4

func transform() -> void:
	if is_fused or current_energy <= 0.0 or equipped_card == null: return
	is_fused = true
	fused_state_changed.emit(true)
	player.move_speed = normal_speed + equipped_card.speed_bonus
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = Color(1, 0.25, 0.25)

func revert() -> void:
	if not is_fused: return
	is_fused = false
	fused_state_changed.emit(false)
	player.move_speed = normal_speed
	mesh.material_override = null

func add_energy(amount: float) -> void:
	current_energy = clamp(current_energy + amount, 0.0, max_energy)
	energy_changed.emit(current_energy, max_energy)

func spend_energy(amount: float) -> void:
	add_energy(-amount)

func set_card(card:FusionCard) -> void:
	equipped_card = card
	card_changed.emit(equipped_card)
	_apply_card_to_abilities()
	if is_fused and equipped_card:
		player.move_speed = normal_speed + equipped_card.speed_bonus

func _apply_card_to_abilities() -> void:
	if abilities == null: return
	abilities.skills = []
	if equipped_card:
		abilities.skills = equipped_card.skills.duplicate()
	# reinitialize cooldown array
	abilities._cooldowns.resize(abilities.skills.size())
	for i in abilities._cooldowns.size():
		abilities._cooldowns[i] = 0.0
