extends CanvasLayer

@export var fusion_path: NodePath
@onready var label: Label = $EnergyPanel/EnergyLabel
@onready var bar: Range = $EnergyPanel/EnergyBar
@onready var card_label: Label = $EnergyPanel/CardLabel

var fusion: Node = null

func _ready() -> void:
	if fusion_path != NodePath():
		fusion = get_node(fusion_path)
		_connect_fusion()

func _connect_fusion() -> void:
	if fusion:
		fusion.energy_changed.connect(_on_energy_changed)
		fusion.fused_state_changed.connect(_on_fused_state_changed)
		if fusion.has_signal("card_changed"):
			fusion.card_changed.connect(_on_card_changed)
		_on_energy_changed(fusion.current_energy, fusion.max_energy)
		_on_card_changed(fusion.equipped_card)

func _on_energy_changed(current: float, max: float) -> void:
	bar.max_value = max
	bar.value = current
	label.text = "Fusion Energy: %d / %d" % [int(current), int(max)]

func _on_fused_state_changed(is_fused: bool) -> void:
	if is_fused: label.text = "Fusion Energy (FUSED)"
	else: label.text = "Fusion Energy"

func _on_card_changed(card) -> void:
	var name = "(none)"
	if card != null and card.display_name != "":
		name = card.display_name
	card_label.text = "Card: %s" % name
