extends Spatial

const i_type_fighter_path = preload('res://scenes/ITypeFighter.tscn')
const spy_ship_path = preload('res://scenes/SpyShip.tscn')
const enemy_types = [
	i_type_fighter_path,
	spy_ship_path,
]

onready var _hi_score_label = $GridContainer/SideMenu/GridContainer/HiScore
onready var _current_score_label = $GridContainer/SideMenu/GridContainer/CurrentScore
onready var _status_label = $GridContainer/SideMenu/GridContainer/Status
onready var _current_round_label = $GridContainer/SideMenu/GridContainer/RoundContainer/CurrentRound
onready var _mini_map = $GridContainer/SideMenu/GridContainer/MiniMap

const FORMATION_OFFSET = 8
const vertical_line_formation = [
	Vector3(0, 0, -FORMATION_OFFSET),
	Vector3(0, 0, -FORMATION_OFFSET * 2),
	Vector3(0, 0, -FORMATION_OFFSET * 3),
	Vector3(0, 0, -FORMATION_OFFSET * 4),
]
const diamond_formation = [
	Vector3(0, 0, -FORMATION_OFFSET),
	Vector3(0, 0, FORMATION_OFFSET),
	Vector3(-FORMATION_OFFSET, 0, 0),
	Vector3(FORMATION_OFFSET, 0, 0),
]
const square_formation = [
	Vector3(-FORMATION_OFFSET, 0, -FORMATION_OFFSET),
	Vector3(FORMATION_OFFSET, 0, -FORMATION_OFFSET),
	Vector3(FORMATION_OFFSET, 0, FORMATION_OFFSET),
	Vector3(-FORMATION_OFFSET, 0, FORMATION_OFFSET),
]
const formation_types = [vertical_line_formation, diamond_formation, square_formation]

const SPAWN_MARGIN = 30
var spawn_points = [Vector3(0, 0, 0)]
const MIN_ENEMY_SPAWNER_TIME = 8
const MAX_ENEMY_SPAWNER_TIME = 20
var enemy_spawner_time = rand_range(MIN_ENEMY_SPAWNER_TIME, MAX_ENEMY_SPAWNER_TIME)
var enemy_spawner_timer = 0


func _ready():
	Global._level = self
	_hi_score_label.text = str(Global.hi_score)
	_current_score_label.text = str(Global.current_score)
	_status_label.text = Global.status
	_current_round_label.text = str(Global.current_round)
	
	spawn_points = [
		Vector3(Global._playing_field.limits['left'] - SPAWN_MARGIN, 0, 0),
		Vector3(Global._playing_field.limits['right'] + SPAWN_MARGIN, 0, 0),
		Vector3(0, 0, -Global._playing_field.limits['top'] - SPAWN_MARGIN),
		Vector3(0, 0, -Global._playing_field.limits['bottom'] + SPAWN_MARGIN),
	]

	randomize()


func _process(delta):
#	spawn_enemy_after_wait_time(delta)
	pass


func spawn_enemy_after_wait_time(delta: float):
	enemy_spawner_timer += delta
	if enemy_spawner_timer > enemy_spawner_time:
		var enemy: KinematicBody = enemy_types[randi() % enemy_types.size()].instance()
		add_child(enemy)
		# place enemy outside of playing field
		enemy.global_transform.origin = spawn_points[randi() % spawn_points.size()]
		_mini_map.add_enemy_ship(enemy)

		enemy_spawner_timer = 0
		enemy_spawner_time = rand_range(MIN_ENEMY_SPAWNER_TIME, MAX_ENEMY_SPAWNER_TIME)


func spawn_squad_formation():
	var lead := i_type_fighter_path.instance()
	lead.is_in_squad = true
	lead.squad_leader = lead
	add_child(lead)
	lead.global_transform.origin = spawn_points[randi() % spawn_points.size()]
	_mini_map.add_enemy_ship(lead)
	
	var formation = formation_types[randi() % formation_types.size()]
	for offset in formation:
		var sub := i_type_fighter_path.instance()
		sub.is_in_squad = true
		sub.squad_leader = lead
		sub.squad_formation_offset = offset
		add_child(sub)
		sub.global_transform.origin = spawn_points[0] + sub.squad_formation_offset
