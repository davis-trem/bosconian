extends Node


const STATUS_GREEN = 'green'
const STATUS_YELLOW = 'yellow'
const STATUS_RED = 'red'
const STATUS_ENEMY_FORMATION = 'enemy_formation'

var hi_score = 20000
var current_score = 0
var status = STATUS_GREEN
var current_round = 1
var _level
var _playing_field

func increase_current_score(points):
	current_score += points
	_level._current_score_label.text = str(current_score)
	
	if current_score > hi_score:
		hi_score = current_score
		_level._hi_score_label.text = str(hi_score)


func set_status(s: String):
	status = s


func find_closest_node_in_list_to_target(target_origin: Vector3, list):
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
