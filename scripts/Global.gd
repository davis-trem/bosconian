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

func increase_current_score(points):
	current_score += points
	_level._current_score_label.text = str(current_score)
	
	if current_score > hi_score:
		hi_score = current_score
		_level._hi_score_label.text = str(hi_score)


func find_closest_node_in_list_to_target(target_origin, list):
	var closest_node
	for node in list:
		if(
			closest_node == null
			or target_origin.distance_to(node.global_transform.origin) <
				target_origin.distance_to(closest_node.global_transform.origin)
		):
			closest_node = node
	return closest_node


func find_closest_player(target_origin):
	var players = get_tree().get_nodes_in_group('player')
	return find_closest_node_in_list_to_target(target_origin, players)
