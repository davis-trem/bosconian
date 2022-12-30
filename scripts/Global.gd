extends Node


const STATUS_GREEN = 'green'
const STATUS_YELLOW = 'yellow'
const STATUS_RED = 'red'
const STATUS_ENEMY_FORMATION = 'enemy formation'
const STATUS_COLORS = {
	STATUS_GREEN: '#008f00',
	STATUS_YELLOW: '#e6dd0d',
	STATUS_RED: '#cd0000',
	STATUS_ENEMY_FORMATION: '#cd0000',
}

var hi_score := 20000
var current_score := 0
var status = STATUS_GREEN
var current_round := 1
var lives := 3
var _level: Level
var _playing_field: PlayingField

func increase_current_score(points):
	current_score += points
	_level._current_score_label.text = str(current_score)
	
	if current_score > hi_score:
		hi_score = current_score
		_level._hi_score_label.text = str(hi_score)


func set_status(s: String):
	status = s
	if status == STATUS_ENEMY_FORMATION:
		_level._condition_label.hide()
		_level._status_label.hide()
		_level._formation_attack_label.show()
		_level._formation_icon.show()
	else:
		_level._formation_attack_label.hide()
		_level._formation_icon.hide()
		_level._condition_label.show()
		_level._status_label.show()
		_level._status_label.text = status + (' !!' if status == STATUS_RED else '')
		# Update label BG Color
		var new_style_box: StyleBoxFlat = _level._status_label.get_stylebox("normal").duplicate()
		new_style_box.bg_color = Color(STATUS_COLORS[status])
		_level._status_label.add_stylebox_override("normal", new_style_box)
	
	if status == STATUS_RED or status == STATUS_ENEMY_FORMATION:
		_level._status_anim_player.play('blinking_text')
	else:
		_level._status_anim_player.stop()


func set_player_lives(l: int):
	lives = l
	var visible_icons = _level._lives_container.get_child_count()
	var remove_icons = visible_icons > lives
	for i in range(abs(visible_icons - lives)):
		if remove_icons:
			_level._lives_container.get_child(i).queue_free()
		else:
			var new_icon = _level._life_icon.duplicate()
			new_icon.show()
			_level._lives_container.add_child(new_icon)


func find_closest_node_in_list_to_target(target_origin: Vector3, list = []):
	var closest_node
	for node in list:
		if(
			closest_node == null
			or target_origin.distance_to(node.global_transform.origin) <
				target_origin.distance_to(closest_node.global_transform.origin)
		):
			closest_node = node
	return closest_node


func find_closest_player(target_origin: Vector3):
	var players = get_tree().get_nodes_in_group('player')
	return find_closest_node_in_list_to_target(target_origin, players)


func find_closest_point_to_play_field_limit(origin: Vector3, direction: Vector3):
	var point_in_bottom = Geometry.ray_intersects_triangle(
		origin,
		direction,
		Vector3(Global._playing_field.limits['left'], 2, -Global._playing_field.limits['bottom'] + 20),
		Vector3(Global._playing_field.limits['right'], 2, -Global._playing_field.limits['bottom'] + 20),
		Vector3(0, -2, -Global._playing_field.limits['bottom'] + 20)
	)
	if point_in_bottom:
		return point_in_bottom

	var point_in_top = Geometry.ray_intersects_triangle(
		origin,
		direction,
		Vector3(Global._playing_field.limits['left'], 2, -Global._playing_field.limits['top'] - 20),
		Vector3(Global._playing_field.limits['right'], 2, -Global._playing_field.limits['top'] - 20),
		Vector3(0, -2, -Global._playing_field.limits['top'] - 20)
	)
	if point_in_top:
		return point_in_top

	var point_in_left = Geometry.ray_intersects_triangle(
		origin,
		direction,
		Vector3(Global._playing_field.limits['left'] - 20, 2, -Global._playing_field.limits['bottom']),
		Vector3(Global._playing_field.limits['left'] - 20, 2, -Global._playing_field.limits['top']),
		Vector3(Global._playing_field.limits['left'] - 20, -2, 0)
	)
	if point_in_left:
		return point_in_left

	var point_in_right = Geometry.ray_intersects_triangle(
		origin,
		direction,
		Vector3(Global._playing_field.limits['right'] + 20, 2, -Global._playing_field.limits['bottom']),
		Vector3(Global._playing_field.limits['right'] + 20, 2, -Global._playing_field.limits['top']),
		Vector3(Global._playing_field.limits['right'] + 20, -2, 0)
	)
	if point_in_right:
		return point_in_right


func direction_towards_and_wrap_field(follower_origin: Vector3, target_origin: Vector3):
	var direct_distance = follower_origin.distance_to(target_origin)
	var direction_to_target = follower_origin.direction_to(target_origin)
	var closet_limit_point_to_follower = find_closest_point_to_play_field_limit(follower_origin, -direction_to_target)
	var closet_limit_point_to_target = find_closest_point_to_play_field_limit(target_origin, direction_to_target)
	
	var wrapped_distance
	if closet_limit_point_to_follower and closet_limit_point_to_target:
		wrapped_distance = (follower_origin.distance_to(closet_limit_point_to_follower)
			+ target_origin.distance_to(closet_limit_point_to_target))
	
	if wrapped_distance and wrapped_distance < direct_distance:
		return follower_origin.direction_to(closet_limit_point_to_follower)
	else:
		return direction_to_target
