extends Resource
class_name FusionCard

enum CardType { ANIMAL, MONSTER, LEGENDARY }

@export var id:String = "wolf_card"
@export var display_name:String = "Wolf"
@export var type:CardType = CardType.ANIMAL
@export var rarity:int = 1             # 1..5
@export var base_stats:StatBlock       # additive stat bonuses while fused
@export var energy_drain_per_sec:float = 6.0
@export var speed_bonus:float = 3.0    # extra move speed while fused
# visuals (optional for now)
@export var fused_scene:PackedScene
@export var transform_vfx:PackedScene
@export var skills:Array[Skill] = []
