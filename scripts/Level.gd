extends Spatial

class_name Level

const player_path = preload('res://scenes/Player.tscn')
const enemy_base_path = preload('res://scenes/EnemyBase.tscn')
const i_type_fighter_path = preload('res://scenes/ITypeFighter.tscn')
const spy_ship_path = preload('res://scenes/SpyShip.tscn')

onready var _hi_score_label = $OverView/SideMenu/SideMenuItems/HiScore
onready var _current_score_label = $OverView/SideMenu/SideMenuItems/CurrentScore
onready var _condition_label = $OverView/SideMenu/SideMenuItems/StatusContainer/Condition
onready var _status_label = $OverView/SideMenu/SideMenuItems/StatusContainer/Status
onready var _formation_attack_label = $OverView/SideMenu/SideMenuItems/StatusContainer/FormationAttack
onready var _formation_icon = $OverView/SideMenu/SideMenuItems/StatusContainer/FormationIcon
onready var _status_anim_player = $OverView/SideMenu/SideMenuItems/StatusContainer/AnimationPlayer
onready var _current_round_label = $OverView/SideMenu/SideMenuItems/RoundContainer/CurrentRound
onready var _mini_map = $OverView/SideMenu/SideMenuItems/MiniMapContainer/MiniMap
onready var _lives_container = $OverView/SideMenu/SideMenuItems/LivesContainer
onready var _life_icon = $OverView/SideMenu/SideMenuItems/LifeIcon
onready var _timer = $Timer
onready var _viewport = $OverView/PlayerViewportContainer/Viewport
onready var _viewport_label = $OverView/PlayerViewportContainer/ViewportLabel
onready var _top_down_camera = $OverView/PlayerViewportContainer/Viewport/TopDownCamera

# Formation Info
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

# Spawn Info
const spawn_padding = 15
var total_enemy_type_weight = 0.0 
var weighted_enemy_types = [
	{'name': 'i_type_fighter', 'type': i_type_fighter_path, 'weight': 1.0},
	{'name': 'spy_ship', 'type': spy_ship_path, 'weight': 0.1},
	{'name': 'formation', 'type': 'formation', 'weight': 0.25},
]
const SPAWN_MARGIN = 30
var spawn_points = [Vector3(0, 0, 0)]
const MIN_ENEMY_SPAWNER_TIME = 8
const MAX_ENEMY_SPAWNER_TIME = 20
var enemy_spawner_time = rand_range(MIN_ENEMY_SPAWNER_TIME, MAX_ENEMY_SPAWNER_TIME)
var enemy_spawner_timer = 0

var current_level = 1


func _ready():
	randomize()

	Global._level = self
	Global.set_status(Global.status)
	Global.set_player_lives(Global.lives)
	_hi_score_label.text = str(Global.hi_score)
	_current_score_label.text = str(Global.current_score)
	_current_round_label.text = str(Global.current_round)

	spawn_points = [
		Vector3(Global._playing_field.limits['left'] - SPAWN_MARGIN, 0, 0),
		Vector3(Global._playing_field.limits['right'] + SPAWN_MARGIN, 0, 0),
		Vector3(0, 0, -Global._playing_field.limits['top'] - SPAWN_MARGIN),
		Vector3(0, 0, -Global._playing_field.limits['bottom'] + SPAWN_MARGIN),
	]
	
	init_level()


func _process(delta):
	spawn_enemy_after_wait_time(delta)


func init_level():
	get_tree().paused = true
	# Remove all enemies and players on level
	var objects_to_remove = get_tree().get_nodes_in_group('enemy_ship')
	objects_to_remove += get_tree().get_nodes_in_group('enemy_base')
	objects_to_remove += get_tree().get_nodes_in_group('player')
	for obj in objects_to_remove:
		obj.queue_free()

	_timer.start()
	_viewport_label.text = 'Ready'
	_viewport_label.show()
	yield(_timer, 'timeout')
	
	# Update spawn probabilities for current level
	for weighted_enemy in weighted_enemy_types:
		if weighted_enemy['name'] == 'spy_ship':
			weighted_enemy['weight'] = clamp(current_level * 0.1, 0.1, 0.7)
		if weighted_enemy['name'] == 'formation':
			weighted_enemy['weight'] = clamp(current_level * 0.25, 0.25, 1)
	
	create_player()

	var amount_of_enemy_bases_to_spawn := int(clamp(current_level + 2, 3, 8))
	# Spawn enemy bases
	for x in range(amount_of_enemy_bases_to_spawn):
		var enemy_base = enemy_base_path.instance()
		enemy_base.oriented_horizontally = (randi() & 1) == 1
		enemy_base.connect('enemy_base_destroyed', self, '_on_enemy_base_destroyed')
		add_child(enemy_base)
		enemy_base.global_transform.origin = get_unique_base_position()

	init_enemy_type_probabilities()
	
	_mini_map.init_markers()
	
	get_tree().paused = false
	_viewport_label.hide()


func advance_to_next_level():
	current_level += 1
	print('play vicorty music')

	get_tree().paused = true
	_timer.start()

	yield(_timer, 'timeout')
	
	get_tree().paused = false
	
	init_level()


func get_unique_base_position() -> Vector3:
	var position = Vector3(
		rand_range(
			Global._playing_field.limits['left'] + spawn_padding,
			Global._playing_field.limits['right'] - spawn_padding),
		0,
		rand_range(
			Global._playing_field.limits['bottom'] + spawn_padding,
			Global._playing_field.limits['top'] - spawn_padding)
	)
	# Avoid overlapping bases
	for base in get_tree().get_nodes_in_group('enemy_base'):
		if (position.distance_to(base.global_transform.origin) < spawn_padding
			or position.distance_to(Vector3.ZERO) < spawn_padding):
			return get_unique_base_position()
	return position


func init_enemy_type_probabilities():
	total_enemy_type_weight = 0.0
	for weighted_enemy in weighted_enemy_types:
		total_enemy_type_weight += weighted_enemy['weight']
		weighted_enemy['acumulated_weight'] = total_enemy_type_weight


func get_random_enemy_type():
	var roll := rand_range(0.0, total_enemy_type_weight)
	for weighted_enemy in weighted_enemy_types:
		if weighted_enemy['acumulated_weight'] > roll:
			return weighted_enemy['type']

	# if sumn goes wrong return this basic ass enemy
	return i_type_fighter_path


func spawn_enemy_after_wait_time(delta: float):
	enemy_spawner_timer += delta
	if enemy_spawner_timer > enemy_spawner_time:
		var random_enemy_type = get_random_enemy_type()
		if random_enemy_type is String and random_enemy_type == 'formation':
			spawn_squad_formation()
		else:
			var enemy: KinematicBody = random_enemy_type.instance()
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
	var enemy_bases = get_tree().get_nodes_in_group('enemy_base')
	lead.global_transform.origin = enemy_bases[randi() % enemy_bases.size()].global_transform.origin
	_mini_map.add_enemy_ship(lead)
	
	var formation = formation_types[randi() % formation_types.size()]
	for offset in formation:
		var sub := i_type_fighter_path.instance()
		sub.is_in_squad = true
		sub.squad_leader = lead
		sub.squad_formation_offset = offset
		add_child(sub)
		sub.global_transform.origin = spawn_points[0] + sub.squad_formation_offset


func create_player():
	var player = player_path.instance()
	player.connect('player_destroyed', self, '_on_player_destroyed')
	player._top_down_camera = _top_down_camera
	_viewport.add_child(player)
	player.global_transform.origin = Vector3.ZERO


func _on_player_destroyed():
	Global.set_player_lives(Global.lives - 1)
#	get_tree().paused = true
	
	_timer.start()
	yield(_timer, 'timeout')
	
	get_tree().paused = true
	if Global.lives == 0:
		_viewport_label.text = 'Game Over'
		_viewport_label.show()
	else:
		_viewport_label.text = 'Ready'
		_viewport_label.show()
		create_player()
		_mini_map.init_markers()
		
		_timer.start()
		yield(_timer, 'timeout')
		
		_viewport_label.hide()
		get_tree().paused = false


func _on_enemy_base_destroyed():
	var enemy_bases_left = get_tree().get_nodes_in_group('enemy_base').size() - 1
	if enemy_bases_left == 0:
		advance_to_next_level()
