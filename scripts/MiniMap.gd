extends MarginContainer


export (NodePath) var playing_field_path

onready var _player_marker = $Player
onready var _enemy_base_marker = $EnemyBase
onready var _enemy_ship_marker = $EnemyShip
onready var _spy_ship_marker = $SpyShip
onready var _playing_field = get_node(playing_field_path)
onready var playing_field_2d_limits = Vector2(
	abs(_playing_field.limits['left']) + abs(_playing_field.limits['right']),
	abs(_playing_field.limits['top']) + abs(_playing_field.limits['bottom'])
)
onready var playing_field_to_rect_rate = Vector2(
	rect_size.x / playing_field_2d_limits.x,
	rect_size.y / playing_field_2d_limits.y
)

var enemy_markers = {}
var player_markers = {}


func _ready():
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player in player_nodes:
		var new_player_marker = _player_marker.duplicate()
		add_child(new_player_marker)
		new_player_marker.show()
		player_markers[player] = new_player_marker

	var enemy_base_nodes = get_tree().get_nodes_in_group('enemy_base')
	for enemy_base in enemy_base_nodes:
		var new_enemy_base_marker = _enemy_base_marker.duplicate()
		add_child(new_enemy_base_marker)
		new_enemy_base_marker.show()
		enemy_markers[enemy_base] = new_enemy_base_marker

	var enemy_ship_nodes = get_tree().get_nodes_in_group('enemy_ship')
	for enemy_ship in enemy_ship_nodes:
		if enemy_ship.is_in_group('spy_ship'):
			var new_enemy_ship_marker = _spy_ship_marker.duplicate()
			add_child(new_enemy_ship_marker)
			new_enemy_ship_marker.show()
			enemy_markers[enemy_ship] = new_enemy_ship_marker
		elif enemy_ship.is_squad_leader:
			var new_enemy_ship_marker = _enemy_ship_marker.duplicate()
			add_child(new_enemy_ship_marker)
			new_enemy_ship_marker.show()
			enemy_markers[enemy_ship] = new_enemy_ship_marker


func _process(delta):
	for player in player_markers:
		if is_instance_valid(player):
			player_markers[player].position.x = (
				(player.translation.x + (playing_field_2d_limits.x / 2))
				* playing_field_to_rect_rate.x)
			player_markers[player].position.y = (
				(player.translation.z + (playing_field_2d_limits.y / 2))
				* playing_field_to_rect_rate.y)

			var player_rotation = (player.rotation.y
				if player._cockpit_camera.current
				else player._model.rotation.y)
			var direction = Vector2(-cos(player_rotation), sin(player_rotation))
			player_markers[player].rotation = direction.angle()
		else:
			player_markers[player].queue_free()
			player_markers.erase(player)

	for enemy in enemy_markers:
		if is_instance_valid(enemy):
			enemy_markers[enemy].position.x = (
				(enemy.translation.x + (playing_field_2d_limits.x / 2))
				* playing_field_to_rect_rate.x)
			enemy_markers[enemy].position.y = (
				(enemy.translation.z + (playing_field_2d_limits.y / 2))
				* playing_field_to_rect_rate.y)
		else:
			enemy_markers[enemy].queue_free()
			enemy_markers.erase(enemy)
