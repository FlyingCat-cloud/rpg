extends Resource
class_name Skill

enum Kind { MELEE, PROJECTILE, BUFF }

@export var id:String
@export var display_name:String
@export var kind:Kind = Kind.MELEE

@export var energy_cost:float = 10.0
@export var cooldown:float = 6.0
@export var power:float = 10.0           # generic "damage" or effect power

# MELEE params
@export var melee_range:float = 1.8       # meters in front of player
@export var melee_radius:float = 1.0      # hitbox radius
@export var melee_duration:float = 0.15   # seconds the hitbox exists

# PROJECTILE params
@export var projectile_scene:PackedScene
@export var projectile_speed:float = 12.0
@export var projectile_lifetime:float = 2.5
